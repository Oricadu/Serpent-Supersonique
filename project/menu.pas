uses wingraph, wincrt;

const
	esc = #27;
	back = #8;
	enter = #13;
	space = #32;
	right = #77;
	left = #75;
	up = #72;
	down = #80;	

type 
	masZm = array[1..900, 1..2] of integer; 
	masPol = array[0..31, 0..31] of integer;
	masBlock = array[1..50, 1..19] of integer;
	
var 
	gd, gm: integer; //initgraph
	
	//=====для меню======//
	fon_m, game_m, help_m, exit_m, kurs, fon_help: pointer; //картинки
	key, ch: char; //считывание клавиш
	yk: integer; //положение курсора
	
	//========для игры========//
	fon,body, head_l,head_r, head_d, head_u, ast_p, planet1, planet2, planet3, planet4, planet5, planet6, planet7, fon_game, score_game, menu_game, lose: pointer; //картинки
	i, j, n, pos_i, pos_j, x_bl, y_bl, k_bl, q, score, th, len, add_ran: integer;
	pole: masPol; // массив игрового поля
	snake: masZm; // змейка
	ast: masBlock; // препятствия
	h_r, h_l, h_u, h_d, b, f, v, a, p1, p2, p3, p4, p5, p6, p7: AnimatType;
	ex: boolean;
	add: string;
	
	
	
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

procedure anim (width, height: integer; filename: string; var anim: AnimatType; col: longint);
var p: pointer;
begin
p := loader(filename);
cleardevice;
putimage(0, 0, p^, 0);
GetAnim(0, 0, width, height, col, anim);
FreeMem(p);
end;

procedure init_MENU;
begin
	yk := 200;

	fon_help := loader('fon_help.bmp');
	
	fon_m := loader('fon_menu.bmp');
	game_m := loader('game.bmp');
	help_m := loader('help.bmp');
	exit_m := loader('exit.bmp');
		
	lose := loader('lose.bmp');
		
	score_game := loader('score_game.bmp');
	menu_game := loader('menu_game.bmp');
	fon_game := loader('fon_game.bmp');		

	anim(60, 60, 'ast.bmp', a, black);
	anim(20, 20, 'planet1_project.bmp', p1, black);
	anim(20, 20, 'planet2_project.bmp', p2, black);
	anim(20, 20, 'planet3_project.bmp', p3, black);
	anim(20, 20, 'planet4_project.bmp', p4, black);
	anim(20, 20, 'planet5_project.bmp', p5, black);
	anim(20, 20, 'planet6_project.bmp', p6, black);
	anim(20, 20, 'planet7_project.bmp', p7, black);
	
		anim(20, 20, 'body_project.bmp', b, black);
		anim(20, 20, 'head_project_down.bmp', h_d, black);
		anim(20, 20, 'head_project_up.bmp', h_u, black);
		anim(20, 20, 'head_project_right.bmp', h_r, black);
		anim(20, 20, 'head_project_left.bmp', h_l, black);
end;

procedure ris_menu;
var i, j: integer;

begin
	putimage(0, 0, fon_m^, 0);
	
	case yk of 
		200: 
		begin
			putimage(500, 0, game_m^, 0);
		end;
		400: 
		begin
			putimage(0, 0, help_m^, 0);
		end;
		600: 
		begin
			putimage(500, 404, exit_m^, 0);
		end;
	end;

end;

procedure GAME;
const
	head_i = 15;
	head_j = 15;	

	
			{ОТРИСОВКА}
	procedure mas_ris_pole;
	var 
		i, j: integer;
		chis, score_t, length: string;
		
	begin
		updategraph(updateoff);
		putimage(0, 0, fon_game^, 0);
		putimage(664, 0, score_game^, 0);
		putimage(664, 346, menu_game^, 0);

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
					putanim((ast[i, 1] - 1) * 20 + 50, (ast[i, 10] - 1)* 20 + 50, a, transput);
					str(ast[i, 19], chis);
					settextstyle(8, 0, 40);
					outtextxy((ast[i, 1]) * 20 + 50, (ast[i, 10] - 1) * 20 + 50, chis);
				end;
			end;
			
			
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
		add_ran := random(n) + th;
		q := random(7) + 1; 
	end;


	procedure appear_ast;
	var 
		i, j, z, n: integer;
		b: boolean;
	begin
		if k_bl <= 15 then
		begin		
			repeat
				x_bl := random(30) + 1;
				y_bl := random(30) + 1;
						
				for i := -1 to 3 do
				begin
					for j := -1 to 3 do
					begin				
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
					ast[k_bl, j] := x_bl + n;
					ast[k_bl, j + 3] := ast[k_bl, j];
					ast[k_bl, j + 6] := ast[k_bl, j];
					
					
					ast[k_bl, (n * 3) + 10] := y_bl + n;
					ast[k_bl, (n * 3) + 11] := y_bl + n;
					ast[k_bl, (n * 3) + 12] := y_bl + n;
					
					inc(n);
				end;	
			
				for i := 1 to k_bl do
					ast[i, 19] := ast[i, 19] + 1;
				
				for i := 1 to 9 do
					pole[ast[k_bl, i + 9], ast[k_bl, i]] := 4;

		end;
	end;
	

	
	
	
			{ПРОЦЕДУРА ДВИЖЕНИЯ ЗМЕЙКИ}
	procedure move;
	var 
		dx, dy, time, time_bl, k, z, l: integer;
		stol, lose: boolean;

			procedure clearSnake;
			var
				t: Integer;

			begin
				for t:= 1 to len do
					pole[snake[t, 2], snake[t, 1]] := 0; 
			end;

			procedure SnakeToPole;
			var
				t: Integer;
			begin
				for t:= 1 to len do
					if t = 1 then
						pole[snake[t, 2], snake[t, 1]] := 1
					else
						pole[snake[t, 2], snake[t, 1]] := 2;
			end;
			
	begin
			dx := 0;
			dy := 0;
			time := 0;
			time_bl := 0;
			k_bl := 1;
			lose := false;
			for i := 0 to k_bl do
				ast[i, 19] := 0;
			
		repeat
		if k_bl > 7 then th := 20;
		if k_bl > 15 then th := 30;
		
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
					
				if (pole[snake[1, 2] + dy, snake[1, 1] + dx] = 2) 
				or (pole[snake[1, 2] + dy, snake[1, 1] + dx] = -1) then 
					lose := true
				else
				
				begin			
					k := 0;
						for i := 1 to 30 do
							for j := 1 to 30 do
							begin
								if pole[i, j] = 3 then
									inc(k);
							end;
						if k = 0 then appear_pl;
						
						if time_bl = 25 then 
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
						str(add_ran, add);
						settextstyle(2, 0, 25);
						outtextxy(850, 275, '+');
						outtextxy(860, 275, add);
						
					
					end;			
					
					if pole[snake[1, 2] + dy, snake[1, 1] + dx] = 4 then
					begin
						
						for i := 1 to k_bl do
						begin
							
							stol := false;
							
							for j := 1 to 9 do
							begin	
								if (ast[i, j] = snake[1, 1] + dx) and 
								(ast[i, j + 9] = snake[1, 2] + dy) then stol := true;
							end;

							if stol then
							begin
								if len - ast[i, 19] <> 0 then 
								begin
							
									if 0 <> ast[i, 19] then
									begin
										clearSnake;
										len := len - 1;
										inc(l);
										dec(ast[i,19]);
										SnakeToPole;
										mas_ris_pole();
										delay(100);
										inc(score,1);
									end;
									
									if 0 = ast[i, 19] then
									begin
										
										for k := 1 to 9 do
											pole[ast[i, k + 9], ast[i, k]] := 0;
										
										for k := i to k_bl do
										begin
											for z := 1 to 19 do
												ast[k, z] := ast[k + 1, z];
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
						if lose then break;

					end;
					
					
					for i := 1 to k_bl do
					begin
						writeln;
						for j := 1 to 19 do
							write(ast[i, j], ' ');
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
					
					end;			
					SnakeToPole;
				end;
				time := 0;
			end;
			
			mas_ris_pole;
			delay(10);
			inc(time);
			
		until (ch = esc) or (len < 1) or (lose);
		if ch = esc then 
			ex := true;
		end;
		


procedure initGame;
var 
	i, j: integer;

begin
	randomize;
	ch := '1';
	len := 1;
	n := 15;
	th := 10;
			{ЗАПОЛНЕНИЕ МАССИВА ПОЛЯ}
	for i := 0 to 31 do
		for j := 0 to 31 do 
		begin
			if (i < 1) or (i > 30) or (j < 1) or (j > 30) then
				pole[i, j] := -1
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
	
end;
	
BEGIN
	score := 0;
	cleardevice;
	setWindowSize(950,700);
	gd := nopalette;
	gm := mCustom;
	initgraph (gd, gm, '');	
	
	initGame;	
	move;	
	
	updategraph(updateon);
	
	ris_menu;
	
	if ex = false then
	begin
		cleardevice;
		putimage(0, 0, lose^, 0);
		readkey;
	end;
	
END;

procedure HELP(fn: string);
  var 
	f: text;
    str: string;
    y, i: integer;
  begin
    cleardevice;
	putimage(0, 0, fon_help^, 0);
    assign(f, fn);
    reset(f);
    y := 250;
	settextstyle(6, 0, 35);
	
	while not eof(f) do
    begin
		readln(f, str);
		outtextxy(100, y, str);
		inc(y, 50);
    end;
	
	putanim(380, 260, p2, transput);
	putanim(410, 260, p3, transput);
	putanim(440, 260, p4, transput);
	putanim(470, 260, p5, transput);
	putanim(500, 260, p6, transput);
	putanim(530, 260, p7, transput);
	putanim(560, 260, p1, transput);
	putanim(700, 290, a, transput);
	
    close(f);
	updategraph(updatenow);
    readkey;
  end;
	
BEGIN
	setWindowSize(950, 700);
	gd := nopalette;
	gm := mCustom;
	initgraph (gd, gm, '');	
	init_MENU;
	ris_menu;
	updategraph(updateoff);

	repeat
		repeat
			key := readkey;
			if key = #0 then key := readkey;
			case key of
				down: if yk < 600 then inc(yk, 200);
				up: if yk > 200 then dec(yk, 200);
			end;
			ris_menu;
			updategraph(updatenow);				
		until key = enter;
		case yk of
			200: GAME;
			400: HELP('help.txt');
		end;
	until yk = 600;		

	closegraph;
END.