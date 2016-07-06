function img = openfdf(path)
%%%
%%%  Wrapper for automatic 2D and 3D fdf image opening in MATLAB, based on 
%%%  Shanrong Zhang's fdf.m
%%%  
%%%  Detects shape of varian fdf images from a directory specified by path and
%%%  opens it into variable img, with unused dimensions omitted.
%%% 
%%%  img(x, y, slice/z, [slab no.], img no., echo no.)
%%%
%%%  Robin Brown
%%%  Department of Neuroimaging
%%%  King's College London
%%%
%%%  robin.brown@kcl.ac.uk

% double check folder name has trailing slash
if ~strcmp(path(end), '/')
    path = [path, '/'];
end

% get dir list
list = dir([path,'*.fdf']);
list = {list.name};

% 2D if image name format is sliceXXXimageXXXechoXXX.fdf
if exist([path,'slice001image001echo001.fdf'], 'file') == 2
    img = fdf2d([path, 'slice001image001echo001.fdf']);
    
    % set 2D img size
    dims = size(img);
    
    % set slice and echo count
    final = char(list(end));
    [dims(3:5)] = str2num(char(regexp(final, '\d+', 'match')));
    
    % zero, resize and fill
    img = zeros(dims);
    
    for slice=1:dims(3)
        for image=1:dims(4)
            for echo=1:dims(5)
                img(:,:, slice, image, echo) = fdf2d([path, sprintf('slice%03dimage%03decho%03d.fdf', slice, image, echo)]);
            end
        end
    end
    
    % remove unnecessary dims
    img = squeeze(img);
    
    return;
    
end

% 3D if image name format is img_slabXXXimageXXXechoXXX.fdf

if exist([path, 'img_slab001image001echo001.fdf'], 'file') == 2
    img = fdf3d([path, 'img_slab001image001echo001.fdf']);
    
    % set 3D img size
    dims = size(img);
    
    % set other dims
    final = char(list(end));
    [dims(4:6)] = str2num(char(regexp(final, '\d+', 'match')));
    
    % zero, resize and fill
    img = zeros(dims);

    for slab=1:dims(4)
        for image=1:dims(5)
            for echo=1:dims(6)
                img(:,:,:, slab, image, echo) = fdf3d([path, sprintf('img_slab001image001echo%03d.fdf', slab, image, echo)]);
            end
        end
    end

    % remove unnecessary dims
    img = squeeze(img);
    
    return
    
end

error('No .fdf files found in %s', path);

end