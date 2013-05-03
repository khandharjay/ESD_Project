#!/usr/bin/perl

use warnings;

use strict;

#use Chart::Gnuplot;

use HiPi::BCM2835::I2C;



#used internally
use HiPi::BCM2835;

#export some constants
use HiPi::BCM2835::I2C  qw( :i2c );

use HiPi::Utils;

use Time::HiRes qw(usleep  ualarm gettimeofday tv_interval);

use Time::HiRes qw(time);

use Time::HiRes qw(sleep);

my $cur_sec=0;
my $cur_msec=0;
my $prev_sec=0;
my $prev_msec=0;
my $temp_sec=0;
my $temp_msec=0;
my $count=0;

HiPi::BCM2835->bcm2835_init();


#Open the device and get a device handler
# 0x1D is the accelerometer addess
my $dev = HiPi::BCM2835::I2C->new( address => 0x1D );



#try to set and then get the current baud rate

my $baud = 100000;

$dev->set_baudrate($baud);

$baud=0;

$baud = $dev->get_baudrate();

print qq(The Current Baud is $baud \n);




#Read the Accelerometers Who Am I register

my $who_am_i= 0x0D;

my $numbytes= 0x01;

my ($value)=$dev->i2c_read_register_rs($who_am_i, 1);

print qq(The register who am i at location $who_am_i is $value\n);





#Bring the device into standby mode before changing it configuration register values
my $ctrl_reg_1=0x2A;

my ($ctrl_reg_val)=$dev->i2c_read_register_rs($ctrl_reg_1,1);

print qq(The value read from the Control register is $ctrl_reg_val\n);

#Make the LSB 0 to make it go to standby mode

($ctrl_reg_val) =($ctrl_reg_val) & 0xFE;

$dev->i2c_write($ctrl_reg_1,($ctrl_reg_val));

#Read Back the value just to be sure

usleep(1000);

($ctrl_reg_val)=$dev->i2c_read_register_rs($ctrl_reg_1,1);

print qq(The value read from the Control register after the device is in standby mode is ($ctrl_reg_val)\n);





my $xyz_data_cfg=0x0E;

#Write 0x00 to the xyz_cfg_register,GSCALE of 2

$dev->i2c_write($xyz_data_cfg,0x00);

my ($xyz_cfg_val)=$dev->i2c_read_register_rs($xyz_data_cfg,1);

print qq(The data config reg is now set to $xyz_cfg_val\n);




#Bring the Accelerometer to active Mode

($ctrl_reg_val)=$dev->i2c_read_register_rs($ctrl_reg_1,1);


($ctrl_reg_val) = ($ctrl_reg_val) | 0x01;

$dev->i2c_write($ctrl_reg_1,($ctrl_reg_val));

#Read Back the value just to be sure

($ctrl_reg_val)=$dev->i2c_read_register_rs($ctrl_reg_1,1);

print qq(The value read from the Control register after the device is set to be in active mode is $ctrl_reg_val\n);


#The same Initialization Procedure for the gyroscope

my $dev2 = HiPi::BCM2835::I2C->new( address => 0x6B );



#Read the Gyroscope Who Am I register

my $who_am_i_gyro= 0x0F;

($value)=$dev2->i2c_read_register_rs($who_am_i_gyro, 1);

print qq(The register who am i at location $who_am_i_gyro is $value\n);


#Start initializing the Gyro Registers
my $ctrl_reg_1_gyro=0x20;

my $ctrl_r1_gyro_val=0x0F;

$dev2->i2c_write($ctrl_reg_1_gyro,$ctrl_r1_gyro_val);


my $ctrl_reg_2_gyro=0x21;

my $ctrl_r2_gyro_val=0x00;

$dev2->i2c_write($ctrl_reg_2_gyro,$ctrl_r2_gyro_val);


my $ctrl_reg_3_gyro=0x22;

my $ctrl_r3_gyro_val=0x08;

$dev2->i2c_write($ctrl_reg_3_gyro,$ctrl_r3_gyro_val);


my $ctrl_reg_4_gyro=0x23;

my $ctrl_r4_gyro_val=0x00;

$dev2->i2c_write($ctrl_reg_4_gyro,$ctrl_r4_gyro_val);


my $ctrl_reg_5_gyro=0x24;

my $ctrl_r5_gyro_val=0x00;

$dev2->i2c_write($ctrl_reg_5_gyro,$ctrl_r5_gyro_val);


#Delay 0f 5ms required for the gyro
usleep(5000);






#Start the reading process


#Accelerometer Variables
my $x_low=0x02;
my $x_high=0x01;

my ($x_low_val)=0x00;
my ($x_high_val)=0x00;
my $x_final=0x00;

my $y_low=0x04;
my $y_high=0x03;

my ($y_low_val)=0x00;
my ($y_high_val)=0x00;
my $y_final=0x00;

#Gyroscope Variables
my $x_low_gyro =0x28;
my $x_high_gyro=0x29;

my ($x_low_val_gyro)=0x00;
my ($x_high_val_gyro)=0x00;
my $x_final_gyro=0x00;



my $gyro_backup=0;

#print "Hello World!\n";
#my $path_write= "./from_Perl";

    #First Perl opens its write pipe
 #   unless (-p $path_write)
 #   { system("mkfifo -m 0666 $path_write"); }

($prev_sec,$prev_msec)=gettimeofday;
my $overall_angle=0;
my $loop_time=0;
open (MYFILE,'>angle_data.txt');
my $result_string="";
my $loop_count=1000;
    while($loop_count>0)
    {
    #open(FIFO1, "> $path_write")|| die "Perl::Failed to open write pipe $! \n";
    #print qq(Perl::Write Pipe Created and Opened\n);
    $loop_count--;

    #Read the Accelerometer values
     ($y_high_val)=$dev->i2c_read_register_rs($y_high,1);

     ($y_low_val)=$dev->i2c_read_register_rs($y_low,1);

     $y_final=( ($y_high_val)<< 8) |  ($y_low_val);

     $y_final= $y_final>>4;
    	
     #my $result1=sprintf("%05d",$y_final);    
     #print qq(The acc value is $y_final\n);
     #print FIFO1 $result1;
    
     #Get the timestamp
     ($cur_sec,$cur_msec)=gettimeofday;
     
     $temp_sec= $cur_sec * 1000000+ $cur_msec;
    

     $prev_sec= $prev_sec * 1000000+ $prev_msec;
	
     $temp_sec=$temp_sec-$prev_sec;
     
     $loop_time=$temp_sec;
     $loop_time=$loop_time /1000000;

    # $temp_msec=$temp_sec%1000000;
     
    # $temp_sec=int($temp_sec/1000000);

    # $loop_time=$temp_msec+ $temp_sec;

     $prev_sec=$cur_sec;
     $prev_msec=$cur_msec;
     #$result1=sprintf("%01d%04d",$temp_sec,$temp_msec);
      	
     #print FIFO1 $result1;


     #Read the Gyroscope  values
     ($x_high_val_gyro)=$dev2->i2c_read_register_rs($x_high_gyro,1);

     ($x_low_val_gyro)=$dev2->i2c_read_register_rs($x_low_gyro,1);

     $x_final_gyro=( ($x_high_val_gyro)<< 8) |  ($x_low_val_gyro);

    
      if($x_final_gyro>50000)
	{
		$x_final_gyro=$gyro_backup;
	}
      else
	{	
		$gyro_backup=$x_final_gyro;
	}
      #$result1=sprintf("%05d",$x_final_gyro);   
      #print qq(The gyro value is $x_final_gyro\n); 
      #print FIFO1 $result1;
      $count++;
      #sleep(1);   
      #close FIFO1;
      $x_final_gyro = $x_final_gyro * 8.75/1000;
	
      $y_final= $y_final * 2.0/2048.0;
       
      $overall_angle= (0.98 * ($overall_angle + $x_final_gyro * $loop_time)) + (0.02 * $y_final * 57.29);
      
      print qq(Gyro:: $x_final_gyro  Acc::$y_final  Loop Time:: $loop_time\n);

      print qq(The overall angle is $overall_angle\n); 
      print qq(   \n);
      
      $result_string=sprintf("%d %lf\n",$count,$overall_angle);
      print MYFILE $result_string;

      if( $loop_time < 0.02)
	{
	    usleep(100);
	}




        } 
#end of for loop

close(MYFILE);
