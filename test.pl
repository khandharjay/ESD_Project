

#!/usr/bin/perl


# Code that conputes the current orientation of the board with respect to horizontal.


use warnings;

use strict;

#We make use of the HiPi BCM2835 I2C library, which is able to generate a repeated start signal, which is required by the accelerometer.


use HiPi::BCM2835::I2C;



#used internally
use HiPi::BCM2835;

#export some constants from 
use HiPi::BCM2835::I2C  qw( :i2c );

use HiPi::Utils;


#Import the library that has functions for delay.
use Time::HiRes qw(usleep  ualarm gettimeofday tv_interval);

use Time::HiRes qw(time);

use Time::HiRes qw(sleep);


#Variables used to compute the loop time.
my $cur_sec=0;
my $cur_msec=0;
my $prev_sec=0;
my $prev_msec=0;
my $temp_sec=0;
my $temp_msec=0;
my $count=0;

#Call the init() from the library.
HiPi::BCM2835->bcm2835_init();


#Open the device and get a device handler, that can be used to perform further transactions on the bus.
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

#Write 0x00 to the xyz_cfg_register,GSCALE of 2, which means the accelerometer readings are in the range of +2G to -2G

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

#Enable the X,Y,Z axis of the gyro and bring it into active mode.
my $ctrl_reg_1_gyro=0x20;

my $ctrl_r1_gyro_val=0x0F;

$dev2->i2c_write($ctrl_reg_1_gyro,$ctrl_r1_gyro_val);


#Disbaling the High Pass filter mode selection set to OFF.
my $ctrl_reg_2_gyro=0x21;

my $ctrl_r2_gyro_val=0x00;

$dev2->i2c_write($ctrl_reg_2_gyro,$ctrl_r2_gyro_val);



#Enabling the DRDY pin of the gyro.
my $ctrl_reg_3_gyro=0x22;

my $ctrl_r3_gyro_val=0x08;

$dev2->i2c_write($ctrl_reg_3_gyro,$ctrl_r3_gyro_val);



#Set the Full Scale to 250 degrees per second, litte endian memory.
my $ctrl_reg_4_gyro=0x23;

my $ctrl_r4_gyro_val=0x00;

$dev2->i2c_write($ctrl_reg_4_gyro,$ctrl_r4_gyro_val);


#Disable High Pass Filter and the FIFO
my $ctrl_reg_5_gyro=0x24;

my $ctrl_r5_gyro_val=0x00;

$dev2->i2c_write($ctrl_reg_5_gyro,$ctrl_r5_gyro_val);


#Delay 0f 5ms required for the gyro to write the values to its internal registers
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


#Get the time before starting to read the values.
($prev_sec,$prev_msec)=gettimeofday;
my $overall_angle=0;
my $loop_time=0;
open (MYFILE,'>angle_data.txt');
my $result_string="";
my $loop_count=1000;

#Loop 1000 times and sample the accelerometer and the gyro values.

    while($loop_count>0)
    {
    
    $loop_count--;

    #Read the Accelerometer values
     ($y_high_val)=$dev->i2c_read_register_rs($y_high,1);

     ($y_low_val)=$dev->i2c_read_register_rs($y_low,1);

     $y_final=( ($y_high_val)<< 8) |  ($y_low_val);

     $y_final= $y_final>>4;
    	
    
    
     #Get the timestamp
     ($cur_sec,$cur_msec)=gettimeofday;
     
     $temp_sec= $cur_sec * 1000000+ $cur_msec;
    

     $prev_sec= $prev_sec * 1000000+ $prev_msec;
	
     $temp_sec=$temp_sec-$prev_sec;
     
     $loop_time=$temp_sec;
     $loop_time=$loop_time /1000000;

   #Get the elapsed time between the previous and current sample.

     $prev_sec=$cur_sec;
     $prev_msec=$cur_msec;
     


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
     
      $count++;
     
     
     
     #Get the gyro values in degrees per second.
      $x_final_gyro = $x_final_gyro * 8.75/1000;
	
     #Get the Accelerometer values in terms of G.
      $y_final= $y_final * 2.0/2048.0;
       
     # Use the complementary filter equation to get the angle.
     # The gyro value is the angular velocity, but we need the angle,so we integrate the angular velocity over time.
     # The angle value that is obtained now is passed through the high pass filter.
     
     
     #The problem with the accelerometer values is that, it does give the current orientation,but it also gives the value of the linear acceleration.
     #But we only require the current orientation values from the accelerometer, so we pass its values through a low pass filter.
     
     
     
      $overall_angle= (0.98 * ($overall_angle + $x_final_gyro * $loop_time)) + (0.02 * $y_final * 57.29);
      
      
      print qq(Gyro:: $x_final_gyro  Acc::$y_final  Loop Time:: $loop_time\n);

      print qq(The overall angle is $overall_angle\n); 
      print qq(   \n);
      
      $result_string=sprintf("%d %lf\n",$count,$overall_angle);
      
      # Write all the angle values to a text file, which will be used to print a graph using GNU plot.
      print MYFILE $result_string;


      #Just to make sure the loop time stays constant at 20 ms.
      if( $loop_time < 0.02)
	{
	    usleep(100);
	}




        } 
#end of for loop

close(MYFILE);
