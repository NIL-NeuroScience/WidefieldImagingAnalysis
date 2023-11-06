% Patrick Doran Version 11/1/2022
% This function outputs the triggers for the LEDs when given the triggers
% for the camera as input
function [LED_Output] = fMake_LED_Triggers(settings,CameraOut)

difference_vector = diff(CameraOut);
LED_Output = zeros(length(CameraOut),4);
Index_Off = find(difference_vector == -1);
Index_On = find(difference_vector == 1);

%% If there are 4 LEDS Used
if length(settings.ExposureTimes) == 4
    % Make Empty Vectors for Each LED
    LED1Out = zeros(size(CameraOut));
    LED2Out = LED1Out;
    LED3Out = LED1Out;
    LED4Out = LED1Out;

    tmpOnes1 = ones(Index_Off(1),1);
    tmpOnes2 = ones((Index_Off(2)-Index_On(1)),1);
    tmpOnes3 = ones((Index_Off(3)-Index_On(2)),1);
    tmpOnes4 = ones((Index_Off(4)-Index_On(3)),1);

    LED1Out(1:Index_Off(1)) = tmpOnes1;
    LED2Out(Index_On(1)+1:Index_Off(2)) = tmpOnes2;
    LED3Out(Index_On(2)+1:Index_Off(3)) = tmpOnes3;
    LED4Out(Index_On(3)+1:Index_Off(4)) = tmpOnes4;

    switch settings.LEDOrder(1,:)
        case '470'
            LED_Output(:,1) = LED1Out;
        case '525'
            LED_Output(:,2) = LED1Out;
        case '565'
            LED_Output(:,3) = LED1Out;
        case '625'
            LED_Output(:,4) = LED1Out;
    end

    switch settings.LEDOrder(2,:)
        case '470'
            LED_Output(:,1) = LED2Out;
        case '525'
            LED_Output(:,2) = LED2Out;
        case '565'
            LED_Output(:,3) = LED2Out;
        case '625'
            LED_Output(:,4) = LED2Out;
    end

    switch settings.LEDOrder(3,:)
        case '470'
            LED_Output(:,1) = LED3Out;
        case '525'
            LED_Output(:,2) = LED3Out;
        case '565'
            LED_Output(:,3) = LED3Out;
        case '625'
            LED_Output(:,4) = LED3Out;
    end

    switch settings.LEDOrder(4,:)
        case '470'
            LED_Output(:,1) = LED4Out;
        case '525'
            LED_Output(:,2) = LED4Out;
        case '565'
            LED_Output(:,3) = LED4Out;
        case '625'
            LED_Output(:,4) = LED4Out;
    end
end

%% If 3 LEDs are used
if length(settings.ExposureTimes) == 3
    % Make Empty Vectors for Each LED
    LED1Out = zeros(size(CameraOut));
    LED2Out = LED1Out;
    LED3Out = LED1Out;

    tmpOnes1 = ones(Index_Off(1),1);
    tmpOnes2 = ones((Index_Off(2)-Index_On(1)),1);
    tmpOnes3 = ones((Index_Off(3)-Index_On(2)),1);

    LED1Out(1:Index_Off(1)) = tmpOnes1;
    LED2Out(Index_On(1)+1:Index_Off(2)) = tmpOnes2;
    LED3Out(Index_On(2)+1:Index_Off(3)) = tmpOnes3;

    switch settings.LEDOrder(1,:)
        case '470'
            LED_Output(:,1) = LED1Out;
        case '525'
            LED_Output(:,2) = LED1Out;
        case '565'
            LED_Output(:,3) = LED1Out;
        case '625'
            LED_Output(:,4) = LED1Out;
    end

    switch settings.LEDOrder(2,:)
        case '470'
            LED_Output(:,1) = LED2Out;
        case '525'
            LED_Output(:,2) = LED2Out;
        case '565'
            LED_Output(:,3) = LED2Out;
        case '625'
            LED_Output(:,4) = LED2Out;
    end

    switch settings.LEDOrder(3,:)
        case '470'
            LED_Output(:,1) = LED3Out;
        case '525'
            LED_Output(:,2) = LED3Out;
        case '565'
            LED_Output(:,3) = LED3Out;
        case '625'
            LED_Output(:,4) = LED3Out;
    end

end

%% If 2 LEDs are used
if length(settings.ExposureTimes) == 2
    % Make Empty Vectors for Each LED
    LED1Out = zeros(size(CameraOut));
    LED2Out = LED1Out;

    tmpOnes1 = ones(Index_Off(1),1);
    tmpOnes2 = ones((Index_Off(2)-Index_On(1)),1);

    LED1Out(1:Index_Off(1)) = tmpOnes1;
    LED2Out(Index_On(1)+1:Index_Off(2)) = tmpOnes2;

    switch settings.LEDOrder(1,:)
        case '470'
            LED_Output(:,1) = LED1Out;
        case '525'
            LED_Output(:,2) = LED1Out;
        case '565'
            LED_Output(:,3) = LED1Out;
        case '625'
            LED_Output(:,4) = LED1Out;
    end

    switch settings.LEDOrder(2,:)
        case '470'
            LED_Output(:,1) = LED2Out;
        case '525'
            LED_Output(:,2) = LED2Out;
        case '565'
            LED_Output(:,3) = LED2Out;
        case '625'
            LED_Output(:,4) = LED2Out;
    end
end

%% If One LED is used
if length(settings.ExposureTimes) == 1
    LED1Out = zeros(size(CameraOut));
    tmpOnes1 = ones(Index_Off(1),1);
    LED1Out(1:Index_Off(1)) = tmpOnes1;
    switch settings.LEDOrder(1,:)
        case '470'
            LED_Output(:,1) = LED1Out;
        case '525'
            LED_Output(:,2) = LED1Out;
        case '565'
            LED_Output(:,3) = LED1Out;
        case '625'
            LED_Output(:,4) = LED1Out;
    end
end
end

