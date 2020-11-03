uses wingraph, wincrt, sysutils;
const
	esc = #27;
	back = #8;
	enter = #13;
	space = #32;
	right = #77;
	left = #75;
	up = #72;
	down = #80;
	head_i = 15;
	head_j = 15;

type 
	masZm = array[1..900, 1..2] of integer; 
	masPol = array[0..31, 0..31] of integer;
	masBlock = array[1..50, 1..19] of integer;
var 
	gd, gm, len, head_x, head_y, add_ran: integer;
	body, head_l,head_r, head_d, head_u, fruit, vrag, ast, planet1, planet2, planet3, planet4, planet5, planet6, planet7, fon_game, score_game, menu_game, lose: pointer;
	pole: masPol;
	snake: masZm;
	block: masBlock;
	fon: pointer;
	ch: char;
	h_r, h_l, h_u, h_d, b, f, v, a, p1, p2, p3, p4, p5, p6, p7: AnimatType;
	i, j, n, pos_i, pos_j, x_bl, y_bl, k_bl, q, score: integer;
	
	
	{ПОДГРУЗКА КАРТИНОК (процедура Loader)}
function loader(filename: string): pointer;
var sz: longint;
    p: pointer;
    f: file;
begin
  assign(f, filename);
  reset(f, 1);
  sz := filesize(f);
  getmem(p, sz);
  blockread(f, p^, sz);
  close(f);
  loader := p;
end;
		{ОТРИСОВКА}
procedure mas_ris_pole;
var 
	i, j: integer;
	chis, add, score_t, length: string;

	
begin
	updategraph(updateoff);
	putimage(0, 0, fon_game^, 0);
	putimage(664, 0, score_game^, 0);
	putimage(664, 346, menu_game^, 0);

	{setcolor(white);
	for i := 0 to 30 do
		begin
			line(50, i * 20 + 50, 650, i * 20 + 50 );
			line(i * 20 + 50, 50, i * 20 + 50, 650);
		end;}
		
	
		
	for i := 1 to 30 do
		for j := 1 to 30 do
		begin
			if (pole[i, j] = 1) and (ch = '1')then
				putanim((j - 1) * 20 + 50, (i - 1) * 20 + 50, h_r, transput);

			if (pole[i, j] = 1) and (ch = right)then
				putanim((j - 1) * 20 + 50, (i - 1) * 20 + 50, h_r, transput);
			if (pole[i, j] = 1) and (ch = left)then
				putanim((j - 1) * 20 + 50, (i - 1) * 20 + 50, h_l, transput);
			if (pole[i, j] = 1) and (ch = up)then
				putanim((j - 1) * 20 + 50, (i - 1) * 20 + 50, h_u, transput);
			if (pole[i, j] = 1) and (ch = down)then
				putanim((j - 1) * 20 + 50, (i - 1) * 20 + 50, h_d, transput);	
				
			if pole[i, j] = 2 then
				putanim((j - 1) * 20 + 50, (i - 1) * 20 + 50, b, transput);
			
			if pole[i, j] = 3 then
			begin	
				//q := random(7) + 1;
				case q of 
					1: putanim((j - 1) * 20 + 50, (i - 1) * 20 + 50, p1, transput);
					2: putanim((j - 1) * 20 + 50, (i - 1) * 20 + 50, p2, transput);
					3: putanim((j - 1) * 20 + 50, (i - 1) * 20 + 50, p3, transput);
					4: putanim((j - 1) * 20 + 50, (i - 1) * 20 + 50, p4, transput);
					5: putanim((j - 1) * 20 + 50, (i - 1) * 20 + 50, p5, transput);
					6: putanim((j - 1) * 20 + 50, (i - 1) * 20 + 50, p6, transput);
					7: putanim((j - 1) * 20 + 50, (i - 1) * 20 + 50, p7, transput);
				end;
			end;	
		end;
		
		if k_bl >= 1 then
		begin
			for i := 1 to k_bl - 1 do
			begin
				putanim((block[i, 1] - 1) * 20 + 50, (block[i, 10] - 1)* 20 + 50, a, transput);
				str(block[i, 19], chis);
				settextstyle(8, 0, 40);
				outtextxy((block[i, 1]) * 20 + 50, (block[i, 10] - 1) * 20 + 50, chis);
			end;
		end;
		
		str(add_ran, add);
		settextstyle(2, 0, 25);
		outtextxy((pos_j - 1) * 20 + 53, (pos_i - 1) * 20 + 52, add);
		
		str(score, score_t);
		settextstyle(2, 0, 50);
		outtextxy(770, 175, score_t);
		
		str(len, length);
		settextstyle(2, 0, 50);
		outtextxy(770, 275, length);

	
	updategraph(updatenow);
end;
		

procedure appear_pl;
begin
	repeat
		pos_j := random(30) + 1;
		pos_i := random(30) + 1;
	until pole[pos_i, pos_j] = 0;

	pole[pos_i, pos_j] := 3;
	add_ran := random(n) + 5;
	q := random(7) + 1; 
end;


procedure appear_ast;
var 
	i, j, z, n: integer;
	b: boolean;
begin	
	
	repeat
		
		x_bl := random(30) + 1;
		y_bl := random(30) + 1;
		
		
		for i := -1 to 3 do
		begin
			for j := -1 to 3 do
			begin
				
				//writeln(b, '  ', i, ' ', j);
				
				if pole[y_bl + i, x_bl + j] <> 0 then
				begin
					b := false;
					break; 		

				end
				
				else b := true;				
			end;
			
			if b = false then break;
		end;
	
	until b;
	
	n := 0;
	
		for j := 1 to 3 do
		begin
			block[k_bl, j] := x_bl + n;
			block[k_bl, j + 3] := block[k_bl, j];
			block[k_bl, j + 6] := block[k_bl, j];
			
			
			block[k_bl, (n * 3) + 10] := y_bl + n;
			block[k_bl, (n * 3) + 11] := y_bl + n;
			block[k_bl, (n * 3) + 12] := y_bl + n;
			
			inc(n);
		end;	
		

		for i := 1 to k_bl do
		begin
			block[i, 19] := block[i, 19] + 1;
			//inc(n);
			
		end;
		
		
		for i := 1 to 9 do
		begin
			pole[block[k_bl, i + 9], block[k_bl, i]] := 4;
		end;
end;



		{ПРОЦЕДУРА ДВИЖЕНИЯ ЗМЕЙКИ}
procedure move;
var 
	dx, dy, time, time_bl, k, z, l: integer;
	stol, lose: boolean;

procedure clearSnake;
var
	t:Integer;

begin
	for t:= 1 to len do
		pole[snake[t, 2], snake[t, 1]] := 0; 
				

end;

procedure SnakToPole;
var
	t:Integer;
begin
	for t:= 1 to len do
		if t = 1 then
			pole[snake[t, 2], snake[t, 1]] := 1
		else
			pole[snake[t, 2], snake[t, 1]] := 2;
				

end;
	
begin
	n := 10;
	dx := 0;
	dy := 0;
	time := 0;
	time_bl := 0;
	k_bl := 1;
	lose := false;
	
repeat

	if keypressed then
	begin {считывание направления}
		ch := readkey;
		if ch = #0 then ch := readkey;
		case ch of
			up {#72}: begin dx := 0; dy := -1 end;
			down {#80}: begin dx := 0; dy := 1 end;
			right {#77}: begin dx := 1; dy := 0 end;
			left {#75}: begin dx := -1; dy := 0 end;
		end;
	end;
	
	if time = 10 then
	begin {изменение положения}
	
		
		if (pole[snake[1, 2] + dy, snake[1, 1] + dx] <> 0) 
		and (pole[snake[1, 2] + dy, snake[1, 1] + dx] <> 3)
		and (pole[snake[1, 2] + dy, snake[1, 1] + dx] <> 4) then
		begin
			dx := 0;
			dy := 0;
		end

		
		else
		begin
			
			k := 0;
				for i := 1 to 30 do
					for j := 1 to 30 do
					begin
						if pole[i, j] = 3 then
						begin
							inc(k);							
							//writeln(k);
						end;
					end;
				if k = 0 then appear_pl;
				
				if time_bl = 15 then 
				begin 
					appear_ast; 
					time_bl := 0;
					inc(k_bl);
				end;
				inc(time_bl);
			
			
			if pole[snake[1, 2] + dy, snake[1, 1] + dx] = 3 then
			begin
				inc(len, add_ran);
				pole[pos_i, pos_j] := 0;
			
			end;			
			//writeln(len);
			
			if pole[snake[1, 2] + dy, snake[1, 1] + dx] = 4 then
			begin
				
				for i := 1 to k_bl do
				begin
					
					stol := false;
					
					for j := 1 to 9 do
					begin	
						if (block[i, j] = snake[1, 1] + dx) and 
						(block[i, j + 9] = snake[1, 2] + dy) then stol := true;
					end;

				
					if stol then
					begin
						if len - block[i, 19] <> 0 then 
						begin
												
							if 0 <> block[i, 19] then
							begin
								clearSnake;
								len := len - 1;
								inc(l);
								dec(block[i,19]);
								SnakToPole;
								mas_ris_pole();
								delay(100);
								inc(score,1);
							end;
							
							if 0 = block[i, 19] then
							begin

								
								for k := 1 to 9 do
									pole[block[i, k + 9], block[i, k]] := 0;
								
								for k := i to k_bl - 1 do
								begin
									for z := 1 to 19 do
										block[k, z] := block[k + 1, z]
								end;
								dec(k_bl);
							end;
						end
						else if len < 1 then 
						begin 
							lose := true;
						end;
						if lose then break;
					end;
					if lose then break;
				end;
				writeln(score);
				if lose then break;

			end;
			
			clearSnake;
			
			
			if pole[snake[1, 2] + dy, snake[1, 1] + dx] <> 4 then
			begin
				for i := len downto 2 do
				begin	
					snake[i, 1] := snake[i - 1, 1];
					snake[i, 2] := snake[i - 1, 2];
				end;
				
				for i := len to 600 do
				begin
					snake[i, 1] := snake[len, 1];
					snake[i, 2] := snake[len, 2];
				end;
				
				snake[1, 1] := snake[1, 1] + dx;
				snake[1, 2] := snake[1, 2] + dy;
			
				head_x := head_x + (dx * 20);
				head_y := head_y + (dy * 20);	
			end;
			
			SnakToPole;
	
			{вывод массива поля в консоль}
			
			{for i := 0 to 31 do
			begin
				writeln;
				for j := 0 to 31 do
				write(pole[i,j], ' ');
			end;
			}
			
			{вывод массива блоков в консоль}
			
			{for i := 1 to k_bl do
			begin
				writeln;
				for j := 1 to 19 do
				write(block[i,j], ' ');
				writeln;
			end;
			}
		end;
		time := 0;
	end;
	
	mas_ris_pole;
	delay(10);
	inc(time);

until (ch = esc) or (len < 1) or (lose);
cleardevice;
end;


procedure initGame;
var 
	i, j: integer;

begin
	randomize;
	ch := '1';
	len := 1;

			{КАРТИНКИ}
	begin
		
		body := loader('body_project.bmp');
		head_r := loader('head_project_right.bmp');
		head_l := loader('head_project_left.bmp');
		head_d := loader('head_project_down.bmp');
		head_u := loader('head_project_up.bmp');
		ast := loader('ast.bmp');
		
		lose := loader('lose.bmp');
		
		score_game := loader('score_game.bmp');
		menu_game := loader('menu_game.bmp');
		fon_game := loader('fon_game.bmp');
		
		planet1 := loader('planet1_project.bmp');
		planet2 := loader('planet2_project.bmp');
		planet3 := loader('planet3_project.bmp');
		planet4 := loader('planet4_project.bmp');
		planet5 := loader('planet5_project.bmp');
		planet6 := loader('planet6_project.bmp');
		planet7 := loader('planet7_project.bmp');
		
		putimage(50, 50, planet1^, 0);
		getanim(50, 50, 70, 70, black, p1);
		putimage(50, 50, planet2^, 0);
		getanim(50, 50, 70, 70, black, p2);
		putimage(50, 50, planet3^, 0);
		getanim(50, 50, 70, 70, black, p3);
		putimage(50, 50, planet4^, 0);
		getanim(50, 50, 70, 70, black, p4);
		putimage(50, 50, planet5^, 0);
		getanim(50, 50, 70, 70, black, p5);
		putimage(50, 50, planet6^, 0);
		getanim(50, 50, 70, 70, black, p6);
		putimage(50, 50, planet7^, 0);
		getanim(50, 50, 70, 70, black, p7);

		
		
		putimage(50, 50, ast^, 0);
		getanim(50, 50, 110, 110, black, a);
		
		putimage(50, 50, head_d^, 0);
		getanim(50, 50, 70, 70, black, h_d);
		putimage(50, 50, head_u^, 0);
		getanim(50, 50, 70, 70, black, h_u);
		putimage(50, 50, head_r^, 0);
		getanim(50, 50, 70, 70, black, h_r);
		putimage(50, 50, head_l^, 0);
		getanim(50, 50, 70, 70, black, h_l);
		putimage(50, 50, body^, 0);
		getanim(50, 50, 70, 70, black, b);
		//putimage(50, 50, fruit^, 0);
		//getanim(50, 50, 70, 70, black, f);

	end;
			{ЗАПОЛНЕНИЕ МАССИВА ПОЛЯ}
	for i := 0 to 31 do
		for j := 0 to 31 do 
		begin
			if (i < 1) or (i > 30) or (j < 1) or (j > 30) then
				begin 
					pole[i, j] := -1;
					
					
				end
			else pole[i,j ] := 0;
		end;
	appear_pl;
	pole[pos_i, pos_j] := 3;
	snake[1, 1] := 15;
	snake[1, 2] := 15;
	for i := 2 to len  do
		begin
			snake[i, 1] := 15 - i + 1;
			snake[i, 2] := 15;
			pole[snake[i, 2], snake[i, 1]] := 2;
		end;
		
		{НАЧАЛЬНОЕ ПОЛОЖЕНИЕ ГОЛОВЫ ЗМЕЙКИ}
	pole[snake[1, 2], snake[1, 1]] := 1;
	head_x := 350;
	head_y := 350;
	
end;
		{ТЕЛО ПРОГРАММЫ}
BEGIN
	//sound:=LoadSound('01_Intro.wav');
	//PlaySound('project\01_Intro.wav', 0, SND_ASYNC);	
	fon := loader('fon.bmp');
	setWindowSize(950,700);
	gd := nopalette;
	gm := mCustom;
	initgraph (gd, gm, '');	
	initGame;	
	move;	
	
	cleardevice;
	putimage(0, 0, lose^, 0);
	//readkey;
	closegraph;
END.