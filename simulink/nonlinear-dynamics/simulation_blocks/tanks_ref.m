function platoon_ref(block)

  setup(block);
  
%endfunction

function setup(block)
  
  %% Register number of dialog parameters   
  block.NumDialogPrms = 0;

  %% Register number of input and output ports
  block.NumInputPorts  = 2;
  block.NumOutputPorts = 1;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = 2;
  block.InputPort(1).DirectFeedthrough = false;
  
  block.InputPort(2).Dimensions        = 2;
  block.InputPort(2).DirectFeedthrough = false;
  
  block.OutputPort(1).Dimensions       = 2;
  
  %% Set block sample time to continuous
  block.SampleTimes = [0 0];
  
  %% Setup Dwork
  block.NumContStates = 2;

  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Derivatives',             @Derivative);  
  
%endfunction

function InitConditions(block)

  %% Initialize Dwork
  global mdl;
  
  block.ContStates.Data = mdl.z0;
  
%endfunction

function Output(block)

  block.OutputPort(1).Data = block.ContStates.Data;
  
%endfunction

function Derivative(block)
    global mdl;

    % reference platoon dynamics (4 states) %
    z = block.InputPort(1).Data;
    v = block.InputPort(2).Data;
    
    % dynamics of aggregate tanks 12 and 34 %
    block.Derivatives.Data(1) = f(mdl.gamma, z(1)) + v(1) - ...
                             1/(mdl.A1 + mdl.A2)*phi(mdl.k2, z(1) - z(2));
    block.Derivatives.Data(2) = f(mdl.gamma, z(2)) + v(2) + ...
                             1/(mdl.A3 + mdl.A4)*phi(mdl.k2, z(1) - z(2));

%endfunction