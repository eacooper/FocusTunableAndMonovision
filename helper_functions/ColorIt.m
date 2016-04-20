function [color] = ColorIt(input)
%
% creates RGB values for more pleasing data plotting colors
%
% input can be a single letter (first letter of color name) or full color
% name: reb, orange, yellow, green, blue, purple
% or an index between 1-8

switch input
    
    case {'b','blue',1}
        
        color = [ 51 127 186 ];
        
    case {'y','yellow',2}
        
        color = [ 206 200 104 ];
        
    case {'r','red',3}
        
        color = [ 228 30 38 ];
        
     case {'o','orange',4}
        
        color = [ 245 129 32 ];
        
    case {'g','green',5}
        
        color = [ 76 175 74 ];
        
    case {'p','purple',6}
        
        color = [ 154 80 159 ];
        

        
    case {'m','magenta',7}
        
        color = [ 170 48 93 ];
        
    case {'c','cyan',8}
        
        color = [ 0 174 239 ];
        
end

color = color/255;

