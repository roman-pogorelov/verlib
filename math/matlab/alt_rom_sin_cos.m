close all;
clear;

%% Необходимая разрядность
WIDTH = 16;

% Формирование таблицы синусов
i = 0 : 2^(WIDTH - 2) - 1;
sinTable = round(sin(i/(2^(WIDTH - 2)) * pi / 2) * (2^(WIDTH - 1) - 1));

%% Сохранение значений в файл
fid = fopen ('sin-lut.bin', 'w');
fwrite(fid, sinTable, 'uint16');
fclose(fid);
