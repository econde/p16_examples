current_dir=`pwd`
cd ports/example1/code
p16as in_out.s
cd $current_dir

cd ports/example2/code
p16as led_button.s
cd $current_dir

cd ports/example3/code
p16as led_click.s
cd $current_dir

cd ports/example4/code
p16as 7segment.s
cd $current_dir

cd timers/example1/code
p16as blink1.s
p16as blink2.s
cd $current_dir

cd timers/example2/code
p16as led_temp.s
cd $current_dir

cd timers/example3/code
p16as blink_button.s
cd $current_dir
