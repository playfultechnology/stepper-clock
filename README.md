# stepper-clock
A clock mechanism in which hour and minute hands driven independently by two 28BJY-48 stepper motors

![3D model](images/3d_model.jpg?raw=true)

## Notes
28BJY-48 motors are very cheap, easy to source and use, and often found in hobbyist projects. They can be driven at 5V with 4 signal lines from an Arduino or other microprocessor via a ULN2003 driver. However, they have some noticeable limitations:
 - The gear ratio can differ between units; it generally seems to be either 4076 or 4096 steps per rotation. Note that neither of these numbers is exactly divisible by 360, nor 60, nor 12, so it is impossible to move the motor to an exact hour, minute, or degree of a circle.
 - Worse still, sometimes the gear ratio is not even a whole integer number of steps per revolution: meaning you cannot even rotate one full revolution accurately. 

These motors are intended for opening small vents in car air conditioning / heating systems. As such, they are not designed for continuous rotation, and accumulated error over multiple rotations is not considered a flaw in their design. However, that can present issues if you were trying to use these for accurate movement of clock hands. 
In my use case, this mechanism was for independent movement of hands in an escape room clock mechanism, so accuracy was not a crucial factor. For greater precision, it might be preferable to use a NEMA stepper instead which generally use exactly 200 steps per 360° degrees rotation - i.e. exactly 1.8° per step. However, they are significantly bulkier and more expensive.

Neither 28BJY-48 or NEMA17 stepper motors have any built-in position feedback mechanism. So, in order to be able to reset the hands to a known position, it might be desirable to add a small magnet to the cogs/hands, and a hall sensor to detect a "zero" point as they pass.
