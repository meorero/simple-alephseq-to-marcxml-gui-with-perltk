use strict;
use warnings;
use Tk;
use Tk::FileSelect;
use Win32::GUI();
use File::Slurp;

# Create main window
my $mw = MainWindow->new;
$mw->title("File Converter");

# Frames for buttons and output
my $button_frame = $mw->Frame()->pack(-side => 'left', -fill => 'y');
my $output_frame = $mw->Frame()->pack(-side => 'right', -fill => 'both', -expand => 1);

# Text widget for output
my $output_text = $output_frame->Scrolled('Text', -scrollbars => 'e')->pack(-fill => 'both', -expand => 1);

# Variables
my $selected_file;
my $output_content;

# Button to select file using native Windows dialog
$button_frame->Button(
    -text    => 'Select File',
    -command => sub {
        my $file_dialog = Win32::GUI::GetOpenFileName(
            -filter => [
                'XML Files (*.xml)' => '*.xml',
                'MRC Files (*.mrc)' => '*.mrc',
                'SAV Files (*.sav)' => '*.sav',
                'All Files (*.*)'   => '*.*',
            ],
        );
        if ($file_dialog) {
            $selected_file = $file_dialog;
            $output_text->delete('1.0', 'end');
            eval {
                $output_content = read_file($selected_file);
                $output_text->insert('end', $output_content);
            };
            if ($@) {
                $output_text->insert('end', "Error reading file: $@\n");
            }

            # Enable/disable buttons based on file extension
            if ($selected_file =~ /\.xml$/i) {
                $button_frame->children->[1]->configure(-state => 'normal');  # Enable XML to AlephSEQ
                $button_frame->children->[2]->configure(-state => 'disabled'); # Disable MRC to MARC XML
                $button_frame->children->[3]->configure(-state => 'disabled'); # Disable AlephSEQ to MRC
            } elsif ($selected_file =~ /\.mrc$/i) {
                $button_frame->children->[1]->configure(-state => 'disabled'); # Disable XML to AlephSEQ
                $button_frame->children->[2]->configure(-state => 'normal');  # Enable MRC to MARC XML
                $button_frame->children->[3]->configure(-state => 'disabled'); # Disable AlephSEQ to MRC
            } elsif ($selected_file =~ /\.sav$/i) {
                $button_frame->children->[1]->configure(-state => 'disabled'); # Disable XML to AlephSEQ
                $button_frame->children->[2]->configure(-state => 'disabled'); # Disable MRC to MARC XML
                $button_frame->children->[3]->configure(-state => 'normal');  # Enable AlephSEQ to MRC
            } else {
                $button_frame->children->[1]->configure(-state => 'disabled'); # Disable XML to AlephSEQ
                $button_frame->children->[2]->configure(-state => 'disabled'); # Disable MRC to MARC XML
                $button_frame->children->[3]->configure(-state => 'disabled'); # Disable AlephSEQ to MRC
            }
        }
    }
)->pack(-side => 'top', -fill => 'x');

# Button to convert XML to AlephSEQ
$button_frame->Button(
    -text    => 'Convert XML to AlephSEQ',
    -state   => 'disabled',
    -command => sub {
        my $output_file = $selected_file;
        $output_file =~ s/\.[^.]+$/.sav/;
        my $command = "catmandu convert MARC --type XML to MARC --type ALEPHSEQ < \"$selected_file\" > \"$output_file\"";
        system($command);
        eval {
            $output_content = read_file($output_file);
            $output_content = replace_mms_id($output_content);
            $output_text->delete('1.0', 'end');
            $output_text->insert('end', $output_content);
        };
        if ($@) {
            $output_text->insert('end', "Error reading output file: $@\n");
        }
    }
)->pack(-side => 'top', -fill => 'x');

# Button to convert MRC to MARC XML
$button_frame->Button(
    -text    => 'Convert MRC to MARC XML',
    -state   => 'disabled',
    -command => sub {
        my $output_file = $selected_file;
        $output_file =~ s/\.[^.]+$/.xml/;
        my $command = "catmandu convert MARC --type USMARC to MARC --type XML < \"$selected_file\" > \"$output_file\"";
        system($command);
        eval {
            $output_content = read_file($output_file);
            $output_text->delete('1.0', 'end');
            $output_text->insert('end', $output_content);
        };
        if ($@) {
            $output_text->insert('end', "Error reading output file: $@\n");
        }
    }
)->pack(-side => 'top', -fill => 'x');

# Button to convert AlephSEQ to MRC
$button_frame->Button(
    -text    => 'Convert AlephSEQ to MRC',
    -state   => 'disabled',
    -command => sub {
        my $output_file = $selected_file;
        $output_file =~ s/\.[^.]+$/.mrc/;
        my $command = "catmandu convert MARC --type ALEPHSEQ to MARC --type USMARC < \"$selected_file\" > \"$output_file\"";
        system($command);
        eval {
            $output_content = read_file($output_file);
            $output_text->delete('1.0', 'end');
            $output_text->insert('end', $output_content);
        };
        if ($@) {
            $output_text->insert('end', "Error reading output file: $@\n");
        }
    }
)->pack(-side => 'top', -fill => 'x');

# Clear button
$button_frame->Button(
    -text    => 'Clear',
    -command => sub {
        $output_text->delete('1.0', 'end');
    }
)->pack(-side => 'top', -fill => 'x');

# Save button
$button_frame->Button(
    -text    => 'Save File',
    -command => sub {
        my $save_dialog = Win32::GUI::GetSaveFileName(
            -filter => [
                'All Files (*.*)' => '*.*',
            ],
        );
        if ($save_dialog) {
            eval {
                write_file($save_dialog, $output_content);
                $output_text->insert('end', "\nFile saved as: $save_dialog\n");
            };
            if ($@) {
                $output_text->insert('end', "Error saving file: $@\n");
            }
        }
    }
)->pack(-side => 'top', -fill => 'x');

# Exit button
$button_frame->Button(
    -text    => 'Exit',
    -command => sub {
        exit;
    }
)->pack(-side => 'top', -fill => 'x');

# Help button
$button_frame->Button(
    -text    => 'Help',
    -command => sub {
        $output_text->insert('end', "Help: Select a file and use the appropriate conversion buttons.\n");
    }
)->pack(-side => 'top', -fill => 'x');

# Function to replace MMS ID with sequential numbers
sub replace_mms_id {
    my ($content) = @_;
    my @lines = split /\n/, $content;
    my $counter = 1;
    my $current_mms_id = '';
    my $new_id = sprintf("%09d", $counter);

    foreach my $line (@lines) {
        my $mms_id = substr($line, 0, 12);
        if ($mms_id =~ /^\d{12}$/) {
            if ($mms_id ne $current_mms_id) {
                $current_mms_id = $mms_id;
                $new_id = sprintf("%09d", $counter);
                $counter++;
            }
            substr($line, 0, 18, $new_id);
        } elsif ($mms_id =~ /^\d{9} $/) {
            if ($mms_id ne $current_mms_id) {
                $current_mms_id = $mms_id;
                $new_id = sprintf("%09d ", $counter);
                $counter++;
            }
            substr($line, 0, 18, $new_id);
        }
    }
    return join("\n", @lines);
}

# Main loop
MainLoop;
