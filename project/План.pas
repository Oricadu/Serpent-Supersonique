1. движение змейки
	1) движение головы   ✔
		• движение вправо  ✔
		• движение влево ✔
		• движение вниз ✔
		• движение вверх ✔
		• ограничения  ✔
	2) движение тела ✔
		• отрисовка тела в разном направлении
	
		
2. взаиможействие с объектами ✔
	1) круги ✔
		• появление кругов с цифрами ✔
		• "поедание" кругов с цифрами ✔
			○ увеличение хвоста змейки на колво, обозначенное в круге ✔
			○ отрисовка числа в поле длины ✔
	2) квадраты ✔
		• появление квадратов ✔
		• разбивание квадратов ✔ 
			○ уменьшение хвоста змейки на колво, обозначенное в квадрате ✔
			○ отрисовка числа в поле очков ✔
	3) появление бустов
		• скорость ✔
			○ замедление ✔
			○ ускрение ✔
		• жизни
		• бесконечная длина ✔
		• бессмертие

3. пауза ✔
4. жизни ✔
5. анимация
	1) разбивание блоков
	2) пауза
	3) переход на следующий уровень

6. музыка
	1) столкновение
	2) уничтожение
	3) пауза
	4) выход из паузы
	5) переход на следующий уровень

{
7. переход на следующий уровень 
	• появление большой фигуры
		○ разбивание фигуры
			♦ увеличение скорости змейки
			♦ изменение скина
}		











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
	masZm = array[0..900, 1..2] of integer; 
	masPol = array[0..31, 0..31] of integer;
	masBlock = array[1..50, 1..19] of integer;
	
var 
	gd, gm: integer; //initgraph
	
	//=====для меню======//
	fon_m, game_m, help_m, exit_m, kurs, fon_help, lose_t, lose_p, lose_m, lose: pointer; //картинки
	key, ch: char; //считывание клавиш
	yk, xk: integer; //положение курсора
	
	//========для игры========//
	fon, body, head_l,head_r, head_d, head_u, ast_p, planet1, planet2, planet3, planet4, planet5, planet6, planet7, fon_game, score_game, menu_game: pointer; //картинки
	i, j, n, pos_i, pos_j, x_bl, y_bl, k_bl, q, score, th, len, add_ran: integer;
	pole: masPol; // массив игрового поля
	snake: masZm; // змейка
	ast: masBlock; // препятствия
	b,  heart, boost_sp, boost_sp2, boost_len, boost_li, boost_in, h_r, h_l, h_u, h_d, b_ver, b_gor, b_ug1, b_ug2, b_ug3, b_ug4, f, v, a, p1, p2, p3, p4, p5, p6: AnimatType;
	ex: boolean;
	
	
	
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
	fon_help := loader('fon_help.bmp');
	
	fon_m := loader('fon_menu.bmp');
	game_m := loader('game.bmp');
	help_m := loader('help.bmp');
	exit_m := loader('exit.bmp');
		
	lose := loader('lose.bmp');
	lose_p := loader('lose_play.bmp');
	lose_m := loader('lose_menu.bmp');
	lose_t := loader('lose_top.bmp');
		
	score_game := loader('score_game.bmp');
	menu_game := loader('menu_game.bmp');
	fon_game := loader('fon_game.bmp');		

	anim(20, 20, 'vr.bmp', v, black);
	anim(30, 30, 'speed.bmp', boost_sp, black);
	anim(30, 30, 'speed2.bmp', boost_sp2, black);
	anim(30, 30, 'len.bmp', boost_len, black);
	anim(30, 30, 'life.bmp', boost_li, black);
	anim(60, 60, 'heart.bmp', heart, black);
	
	anim(60, 60, 'ast.bmp', a, black);
	anim(30, 30, 'planet1_project.bmp', p1, black);
	anim(30, 30, 'planet2_project.bmp', p2, black);
	anim(30, 30, 'planet3_project.bmp', p3, black);
	anim(30, 30, 'planet5_project.bmp', p4, black);
	anim(30, 30, 'planet6_project.bmp', p5, black);
	anim(30, 30, 'planet7_project.bmp', p6, black);
	
		anim(20, 20, 'body_ver.bmp', b_ver, black);
		anim(20, 20, 'body_gor.bmp', b_gor, black);
		anim(20, 20, 'body_ug1.bmp', b_ug1, black);
		anim(20, 20, 'body_ug2.bmp', b_ug2, black);
		anim(20, 20, 'body_ug3.bmp', b_ug3, black);
		anim(20, 20, 'body_ug4.bmp', b_ug4, black);
		
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
var
	dx, dy, direction, pre_direction, lifetime: integer;
	po: boolean;
const
	head_i = 15;
	head_j = 15;	

	
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
		
		setcolor(white);
{		for i := 0 to 30 do
		begin
			line(50, i * 20 + 50, 650, i * 20 + 50 );
			line(i * 20 + 50, 50, i * 20 + 50, 650);
		end;
}
		for i := 1 to 30 do
			for j := 1 to 30 do
				begin
					if (pole[i, j] = 1) and (ch = '1')then
						putanim(j * 20 + 30, i * 20 + 30, h_r, transput);
						

					if (pole[i, j] = 1) and (dx = 1) and (dy = 0) then
						putanim(j * 20 + 30, i * 20 + 30, h_r, transput);
					if (pole[i, j] = 1) and (dx = -1) and (dy = 0) then
						putanim(j * 20 + 30, i * 20 + 30, h_l, transput);
					if (pole[i, j] = 1) and (dx = 0) and (dy = -1) then
						putanim(j * 20 + 30, i * 20 + 30, h_u, transput);
					if (pole[i, j] = 1) and (dx = 0) and (dy = 1) then
						putanim(j * 20 + 30, i * 20 + 30, h_d, transput);	
						
					if (pole[i, j] = -1) then
						putanim(j * 20 + 30, i * 20 + 30, v, transput);					
					
				{}	if (pole[i, j] = 2) then
						putanim(j * 20 + 30, i * 20 + 30, b, transput);
						
					{if (pole[i, j] = 4) then
						putanim(j * 20 + 30, i * 20 + 30, b_ug1, transput);
					if (pole[i, j] = 7) then
						putanim(j * 20 + 30, i * 20 + 30, b_ug4, transput);
					if (pole[i, j] = 5) then
						putanim(j * 20 + 30, i * 20 + 30, b_ug2, transput);
					if (pole[i, j] = 6) then
						putanim(j * 20 + 30, i * 20 + 30, b_ug3, transput);
					if (pole[i, j] = 6) then
						putanim(j * 20 + 30, i * 20 + 30, b_ug3, transput);
					if (pole[i, j] = 7) then
						putanim(j * 20 + 30, i * 20 + 30, b_ug4, transput);					
					if (pole[i, j] = 5) then
						putanim(j * 20 + 30, i * 20 + 30, b_ug2, transput);
					if (pole[i, j] = 4) then
						putanim(j * 20 + 30, i * 20 + 30, b_ug1, transput);
						
					if (pole[i, j] = 2) then
						putanim(j * 20 + 30, i * 20 + 30, b_ver, transput);
					if (pole[i, j] = 2) then
						putanim(j * 20 + 30, i * 20 + 30, b_ver, transput);
					if (pole[i, j] = 3) then
						putanim(j * 20 + 30, i * 20 + 30, b_gor, transput);
					if (pole[i, j] = 3) then
						putanim(j * 20 + 30, i * 20 + 30, b_gor, transput);
						} 
					
					if (pole[i, j] = 10) then
						putanim(j * 20 + 25, i * 20 + 30, boost_sp, transput);
					if (pole[i, j] = 11) then
						putanim(j * 20 + 25, i * 20 + 30, boost_sp2, transput);
					if (pole[i, j] = 12) then
						putanim(j * 20 + 25, i * 20 + 30, boost_len, transput);
					if (pole[i, j] = 13) then
						putanim(j * 20 + 25, i * 20 + 30, boost_li, transput);
					
					
					if pole[i, j] = 8 then
					begin	
						case q of 
							1: putanim(j * 20 + 25, i * 20 + 25, p1, transput);
							2: putanim(j * 20 + 25, i * 20 + 25, p2, transput);
							3: putanim(j * 20 + 25, i * 20 + 25, p3, transput);
							4: putanim(j * 20 + 25, i * 20 + 25, p4, transput);
							5: putanim(j * 20 + 25, i * 20 + 25, p5, transput);
							6: putanim(j * 20 + 25, i * 20 + 25, p6, transput);
						end;
					end;	
				end;
			
				for i := 1 to k_bl - 1 do
				begin
					putanim(ast[i, 1] * 20 + 30, ast[i, 10] * 20 + 30, a, transput);
					str(ast[i, 19], chis);
					settextstyle(8, 0, 40);
					outtextxy(ast[i, 1] * 20 + 30, ast[i, 10] * 20 + 30, chis);
				end;
				
			str(add_ran, add);
			settextstyle(2, 0, 25);
			outtextxy(860, 275, '+');
			outtextxy(870, 275, add);
			
			str(score, score_t);
			settextstyle(2, 0, 50);
			outtextxy(770, 175, score_t);
			
			str(len, length);
			settextstyle(2, 0, 50);
			outtextxy(770, 275, length);
			
			for i := 1 to lifetime do
				putanim(650 + i * 70, 400, heart, transput);


		
		updategraph(updatenow);
	end;
	
	procedure appear_pl;
	begin
		repeat
			pos_j := random(30) + 1;
			pos_i := random(30) + 1;
		until pole[pos_i, pos_j] = 0;

		pole[pos_i, pos_j] := 8;
		add_ran := random(n) + th;
		q := random(7) + 1; 
	end;
	
	procedure appear_boost;
	var 
		i_b, j_b: integer;
	begin	
		repeat
			j_b := random(30) + 1;
			i_b := random(30) + 1;
		until (pole[i_b, j_b] = 0) and (pole[i_b, j_b] <> -1) and (pole[i_b, j_b] <> 9);
		
		pole[i_b, j_b] := random(4) + 10; 

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
					if (pole[y_bl + i, x_bl + j] <> 0) or (y_bl + i = 15) or (x_bl + j = 15) then
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
		
		if k_bl >= 1 then
		begin
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
		end; 
		
		for i := 1 to 9 do
			pole[ast[k_bl, i + 9], ast[k_bl, i]] := 9;
	end;
	

	
	
	
			{ПРОЦЕДУРА ДВИЖЕНИЯ ЗМЕЙКИ}
	procedure move;
	var 
		speed, time, time_bl, time_boost, step, ran, k, z, l: integer;
		stol, lose, eat, eat_boost, step_bool: boolean;

			
			procedure pause;			
			begin
				po := not(po);
				writeln(po);
				repeat
					ch := readkey;
					if ch = #0 then ch := readkey;
				until ch = space;
				if ch = space then
				begin
					po := not(po);
					writeln(po);
				end;
			end;
			
			
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
				for t := 1 to len do
					if t = 1 then
						pole[snake[t, 2], snake[t, 1]] := 1
					else
						pole[snake[t, 2], snake[t, 1]] := 2;

				{	else if t = 2 then
					begin	
						if (pre_direction = 3) and (direction = 1)  then
								pole[snake[2, 2], snake[2, 1]] := 4;
						if (pre_direction = 3) and (direction = 2)  then
								pole[snake[2, 2], snake[2, 1]] := 7;
						if (pre_direction = 4) and (direction = 1)  then
								pole[snake[2, 2], snake[2, 1]] := 5;
						if (pre_direction = 4) and (direction = 2)  then
								pole[snake[2, 2], snake[2, 1]] := 6;
						if (pre_direction = 1) and (direction = 3)  then
								pole[snake[2, 2], snake[2, 1]] := 6;
						if (pre_direction = 1) and (direction = 4)  then
								pole[snake[2, 2], snake[2, 1]] := 7;
						if (pre_direction = 2) and (direction = 3)  then
								pole[snake[2, 2], snake[2, 1]] := 5;
						if (pre_direction = 2) and (direction = 4)  then
								pole[snake[2, 2], snake[2, 1]] := 4;
					end
					else if t > 2 then 
					begin
						if (ch = up) and (direction = 1) then
								pole[snake[t, 2], snake[t, 1]] := 2;
						if (ch = down) and (direction = 2) then
								pole[snake[t, 2], snake[t, 1]] := 2;
						if (ch = right) and (direction = 3) then
								pole[snake[t, 2], snake[t, 1]] := 3;
						if (ch = left) and (direction = 4) then
								pole[snake[t, 2], snake[t, 1]] := 3;
					end;
						}
					
			end;
	

			procedure init_characteristics;
			begin
				speed := 15;
				l := 1;
				
				step := 0;
				step_bool := false;
			end;
			
			procedure dec_lifetime;
			begin
				clearSnake;
				len := 1;
				snake[1, 1] := 15;
				snake[1, 2] := 15;
				dec(lifetime);
			end;
			
	begin
		lifetime := 3;
		l := 1;
		dx := 0;
		dy := 0;
		step := 0;
		time := 0;
		time_bl := 0;
		time_boost := 0;
		speed := 15;
		step_bool := false;
		lose := false;
		eat := false;
		eat_boost := false;

		repeat

		if po = false then 
		begin
		
		
				if keypressed then
				begin {считывание направления}
					ch := readkey;
					if ch = #0 then ch := readkey;
					case ch of
						up{1}: 
						begin 
							if len = 1 then
							begin
								dy := -1;
								dx := 0;
							end
							else if dy <> 1 then
							begin
								dy := -1;
								dx := 0;
							end;
							pre_direction := direction;
							direction := 1;
						end;
						down{2}: 
						begin 
							if len = 1 then
							begin
								dy := 1;
								dx := 0;
							end
							else if dy <> -1 then
							begin
								dy := 1;
								dx := 0;
							end;
							pre_direction := direction;
							direction := 2;
						end;
						right{3}: 
						begin 
							if len = 1 then
							begin
								dy := 0;
								dx := 1;
							end
							else if dx <> -1 then
							begin
								dy := 0;
								dx := 1;
							end;
							pre_direction := direction;
							direction := 3;
						end;
						left{4}: 
						begin 
							if len = 1 then
							begin
								dy := 0;
								dx := -1;
							end
							else if dx <> 1 then
							begin
								dy := 0;
								dx := -1;
							end;
							pre_direction := direction;
							direction := 4;
						end;
						space: pause;
					end;
				end;
				
				if time = speed then
				begin {изменение положения}
						
					if (pole[snake[1, 2] + dy, snake[1, 1] + dx] = 2) 
					or (pole[snake[1, 2] + dy, snake[1, 1] + dx] = -1) then 
						dec_lifetime
					else
					
					begin
							
						if eat then
						begin
							if time_bl = 20 then 
							begin 
								for i := 1 to k_bl do
									inc(ast[i, 19]);
									//writeln(k_bl);
									
								if k_bl < 15 then
								begin
									appear_ast; 
									inc(k_bl);
									time_bl := 0;
									//writeln(k_bl);
								end
								else time_bl := 0;
							end;
						end;
						
						if eat then inc(time_bl); 
						//writeln(time_bl);		
						if pole[snake[1, 2] + dy, snake[1, 1] + dx] = 8 then
						begin
							inc(len, add_ran);
							pole[pos_i, pos_j] := 0;
							eat := true;
							appear_pl;
							//writeln(eat);
						end;			
						
						if pole[snake[1, 2] + dy, snake[1, 1] + dx] = 9 then
						begin
							
							for i := 1 to k_bl do
							begin
								
								stol := false;
								
								for j := 1 to 9 do	
									if (ast[i, j] = snake[1, 1] + dx) and 
									(ast[i, j + 9] = snake[1, 2] + dy) then 
										stol := true;
								if stol then
								begin
									if len - ast[i, 19] <> 0 then 
									begin
								
										if ast[i, 19] <> 0 then
										begin
											clearSnake;
											dec(len, l);
											dec(ast[i, 19]);
											SnakeToPole;
											mas_ris_pole();
											delay(100);
											inc(score);
											if len < 1 then dec_lifetime;
										end;
										
										if ast[i, 19] = 0 then
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
									end;									
								end;
							end;
						end;
						
						clearSnake;
						
				BEGIN//=============================boosts================================//
						if time_boost = ran then
						begin
							if eat_boost = true then
							begin
								appear_boost;
								time_boost := 0;
								eat_boost := false;
								step_bool := false;
							end;
						end;
					
						if time_boost = 0 then 
						begin
							ran := random(20) + 100; 
							//writeln('ran = ', ran);
						end;
						
						if (eat_boost = true) and (step = 0) then
							inc(time_boost); //writeln(time_boost);
						
						if pole[snake[1, 2] + dy, snake[1, 1] + dx] = 10 then
						begin
							speed := 30;
							pole[snake[1, 2] + dy, snake[1, 1] + dx] := 0;
							eat_boost := true;
							step_bool := true;
							step := 0;
							//writeln(eat_boost);
						end;	

						if pole[snake[1, 2] + dy, snake[1, 1] + dx] = 11 then
						begin
							speed := 5;
							pole[snake[1, 2] + dy, snake[1, 1] + dx] := 0;
							eat_boost := true;
							step_bool := true;
							step := 0;
							//writeln(eat_boost);
						end;	
						
						
						if pole[snake[1, 2] + dy, snake[1, 1] + dx] = 12 then
						begin
							l := 0;
							pole[snake[1, 2] + dy, snake[1, 1] + dx] := 0;
							eat_boost := true;
							step_bool := true;
							step := 0;
							//writeln(eat_boost);
						end;	
						
						if pole[snake[1, 2] + dy, snake[1, 1] + dx] = 13 then
						begin
							inc(lifetime);
							pole[snake[1, 2] + dy, snake[1, 1] + dx] := 0;
							eat_boost := true;
							step_bool := true;
							step := 0;
							//writeln(eat_boost);
						end;	
						
						
						if step >= 30 then 
						begin
							init_characteristics;
							delay(100);
						end;
													//writeln(eat_boost);
				END;		
				
				
						if pole[snake[1, 2] + dy, snake[1, 1] + dx] <> 9 then
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
						
						BEGIN//--------вывод массива блоков---------//
						{for i := 1 to k_bl do
						begin
							writeln;
							for j := 1 to 19 do
								write(ast[i, j], ' ');
						end;
						}END;
						
						BEGIN//--------вывод массива поля---------//
						for i := 0 to 31 do
						begin
							writeln;
							for j := 0 to 31 do
								write(pole[i, j], ' ');
						end;
						writeln;
						END;
						
					end;
					time := 0;
					if step_bool = true then
					begin
						inc(step); 
						//writeln(step);
					end;
				end;
				
				mas_ris_pole;
				delay(10);
				inc(time);
					//writeln(lifetime);
		end;
			
				
		until (ch = esc) or (lifetime = 0);
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
	score := 0;
	k_bl := 1;
	po := false;
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
		
				{ОБНУЛЕНИЕ МАССИВА АСТЕРОИДОВ}
	for i := 1 to k_bl do
		ast[i, 19] := 0;
		
		
	appear_pl;
	appear_boost;
	snake[1, 1] := 15;
	snake[1, 2] := 15;
	
	{for i := 2 to len  do
		begin
			snake[i, 1] := 15 - i + 1;
			snake[i, 2] := 15;
			pole[snake[i, 2], snake[i, 1]] := 2;
		end;
	}	
		{НАЧАЛЬНОЕ ПОЛОЖЕНИЕ ГОЛОВЫ ЗМЕЙКИ}
	pole[snake[1, 2], snake[1, 1]] := 1;
	
end;




procedure pr_exit;
var 
	xk: integer;
	
	procedure ris_exit;
	var i, j: integer;

	begin
		putimage(0, 0, lose^, 0);
		
		case xk of 
			300: 
			begin
				putimage(0, 0, lose_t^, 0);
			end;
			600: 
			begin
				putimage(320, 363, lose_p^, 0);
			end;
			900: 
			begin
				putimage(611, 363, lose_m^, 0);
			end;
		end;

	end;
begin
	
	cleardevice;
	xk := 600;	
	ris_exit;
	updategraph(updateoff);

	repeat
		repeat
			key := readkey;
			if key = #0 then key := readkey;
			case key of
				right: if xk < 900 then inc(xk, 300);
				left: if xk > 300 then dec(xk, 300);
			end;
			writeln(xk);
			ris_exit;
			updategraph(updatenow);				
		until key = enter;
		case xk of
			300: cleardevice;
			600: GAME;
		end;
	until xk = 900;
	putimage(0, 0, fon_m^, 0);
	ris_menu;
	updategraph(updatenow);
end;
	
BEGIN
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
		pr_exit;	
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
	putanim(470, 260, p4, transput);
	putanim(500, 260, p5, transput);
	putanim(530, 260, p6, transput);
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

	yk := 200;
	updategraph(updatenow);
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

