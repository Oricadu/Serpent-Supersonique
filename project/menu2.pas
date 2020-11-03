uses wingraph, wincrt, inifiles, mmsystem, winmouse, sysutils;

const
	esc = #27;
	back = #8;
	enter = #13;
	backspace = #8;
	space = #32;
	right = #77;
	left = #75;
	up = #72;
	down = #80;	
	
	k = 40; {количество картинок}
	b = 11; {количество картинок boost}
	p = 6; {количество картинок планет}
	s = 12; {количество картинок змеи}
	bmp_f: array[1..k] of string = ('vr.bmp', 'fon_help.bmp', 'fon_menu.bmp', 'game.bmp', 'help.bmp', 'exit.bmp', 'lose.bmp',
	'lose_play.bmp', 'lose_menu.bmp', 'lose_top.bmp', 'score_game.bmp', 'menu_game.bmp', 'fon_game.bmp', 'top.bmp', 'top_1.bmp', 'fon_top.bmp', 'back2.bmp', 'menu2.bmp', 'next2.bmp', 'back3.bmp', 'next3.bmp', 
	'back_top.bmp', 'back_top2.bmp', 'fon_help_1.bmp', 'fon_help_2.bmp', 'fon_help_3.bmp', 'fon_help_4.bmp', 'fon_help_5.bmp', 'fon_help_6.bmp', 'fon_help_7.bmp', 'fon_help_8.bmp',
	'shop_01.bmp', 'shop_02.bmp', 'shop_03.bmp', 'shop_04.bmp', 'shop_05.bmp', 'shop_06.bmp', 'shop_07.bmp', 'shop_08.bmp', 'shop_09.bmp');
	anim_boost: array[1..b] of string = ('speed.bmp', 'speed2.bmp', 'len.bmp', 'life.bmp', 'heart.bmp', 'stena.bmp', 'speed_1.bmp', 'speed_2.bmp', 'length1.bmp', 'score.bmp', 'score1.bmp');
	plan: array[1..p] of string = ('planet1_project.bmp', 'planet2_project.bmp', 'planet3_project.bmp', 'planet4_project.bmp', 'planet5_project.bmp', 'planet6_project.bmp');
	snake_img: array[1..s] of string = ('ast.bmp', 'body_project.bmp', 'head_project_down.bmp', 'head_project_up.bmp', 'head_project_right.bmp', 
	'head_project_left.bmp', 'body_ver.bmp', 'body_gor.bmp', 'body_ug1.bmp', 'body_ug2.bmp', 'body_ug3.bmp', 'body_ug4.bmp');


type 
	masZm = array[0..900, 1..3] of integer; 	
	masPol = array[0..31, 0..31] of integer;
	masBlock = array[1..50, 1..19] of integer;
	
	sc = array[1..10] of integer;
	na = array[1..10] of string;
		
var 
	gd, gm: integer; //initgraph
	ini: Tinifile;
	me: MouseEventType;
	
	//=====для меню======//
	bmp: array[1..k] of pointer;
	mas_boost: array[1..b] of AnimatType;
	planet: array[1..p] of AnimatType;
	sn: array[1..s] of AnimatType;

	key, ch: char; //считывание клавиш
	xk, yk, state: longint; //положение курсора
	score_t: string;
	click, flag: boolean;
	
	//========для игры========//
	i, j, n, pos_i, pos_j, x_bl, y_bl, k_bl, q, score, th, len, add_ran: integer;
	pole: masPol; // массив игрового поля
	snake: masZm; // змейка
	ast: masBlock; // препятствия
	ex, pm, m, mes: boolean;
	
	
	
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


procedure CheckMouse;
var me: MouseEventType; 
begin
	if not(PollMouseEvent(me)) then Exit;
	GetMouseEvent(me);
	with me do
	case action of 
		MouseActionDown: 
		begin //mouse button pressed 
			case buttons of
				MouseLeftButton: 
				begin //Left button 
					click := true;
				end;
			end; 
		end;

 	end;
end;


procedure init_MENU;
begin

	for i := 1 to k do 
		bmp[i] := loader(bmp_f[i]);

	for i := 1 to b do
	begin
		if i = 5 then anim(40, 40, anim_boost[i], mas_boost[i], black)
		else if  ((i >= 7) and (i < 10)) or (i = 10 ) then anim(50, 50, anim_boost[i], mas_boost[i], black)
		else anim(20, 20, anim_boost[i], mas_boost[i], black);
	end;
	for i := 1 to p do 
		anim(30, 30, plan[i], planet[i], black);
		
	for i := 1 to s do 
	begin
		if i = 1 then		
			anim(60, 60, snake_img[i], sn[i], black)
		else
			anim(20, 20, snake_img[i], sn[i], black);
	end;		
end;


procedure TOP;
var	
	i, pos: integer;
	p, name: string;
	score_top: sc;
	score_str: na;
	name_top: na;
	b: boolean;
	
	
	procedure ris_TOP;
	var
		j: integer;
	begin
		putimage(0, 0, bmp[16]^, 0);
		putimage(0, 465, bmp[22]^, 0);
		
		for j := 1 to 10 do
		begin
			str(j, p);
			score_top[j] := ini.readInteger('scores', p, 0);
			name_top[j] := ini.readString('names', p, '');
			str(score_top[j], score_str[j]);
		end;

		
		for j := 1 to 10 do 
		begin
			outtextxy(450, 115 + j * 50, name_top[j]);
			if score_top[j] <> 0 then
				outtextxy(750, 115 + j * 50, score_str[j]);
			if( pos = j ) then
			begin
				outtextxy(450, 115 + pos * 50, name);
			end;
		end;
		
		if (xk > 34) and (xk < 339) and (yk > 562) and (yk < 650) then
			putimage(0, 465, bmp[23]^, 0);
		
		updategraph(updatenow);
	end;
	
		
	procedure write_TOP;
	var
		j: integer;
	begin		
		for j := pos to 9 do
		begin
			str(j + 1, p);
			ini.writeInteger('scores', p, score_top[j]);
			ini.writeString('names', p, name_top[j]);	
		end;
	
		str(pos, p);
		ini.writeInteger('scores', p, score);
		ini.writeString('names', p, '');
		
		name := '';
		ris_TOP;
		writeln( '  ', pos);
		repeat
			writeln(pos);
			ch := readkey;
			if ch = #0 then ch := readkey;
			if  ch = backspace then
			begin
				delete(name, length(name), 1);
				ris_TOP; writeln(pos, ' 1');
			end
			else if length(name) < 14 then
				name := name + ch; 
				
			ris_TOP;
		until ch = enter;
		
		str(pos, p);
		ini.writeString('names', p, name);
		score := 0;
	end; 
	
	
begin
	ini := TINIFile.Create('TOP.ini');
	settextstyle(1, 0, 40);
	b := false;
	
	for i := 1 to 10 do
	begin
		str(i, p);
		score_top[i] := ini.readInteger('scores', p, 0);
		name_top[i] := ini.readString('names', p, '');
		str(score_top[i], score_str[i]);
	end;
		
	
	for i := 1 to 10 do
	begin
		if score > score_top[i] then
		begin
			b := true;
			pos := i;
			break;
		end;
	end;
	
	
	if b then
	begin
		write_TOP;
	end
	else
	begin
		ris_TOP;
	end;
	
	repeat
		click := false;
		flag := false;
		ris_TOP;
		CheckMouse;
		xk := GetMouseX;
		yk := GetMouseY;
		if (xk > 34) and (xk < 339) and (yk > 562) and (yk < 650) and (click) then
			flag := true;	
		delay(10);

	until (flag) or (closegraphrequest);
end;




procedure ris_menu;
var 
	i, j: integer;


begin
	
	putimage(0, 0, bmp[3]^, 0);
    xk := GetMouseX;
    yk := GetMouseY;
	if (xk > 47) and (xk < 230) and (yk > 186) and (yk < 368) then
		putimage(0, 0, bmp[5]^, 0);
	if (xk > 112) and (xk < 298) and (yk > 486) and (yk < 669) then
		putimage(0, 404, bmp[15]^, 0);
	if (xk > 712) and (xk < 902) and (yk > 61) and (yk < 251) then
		putimage(500, 0, bmp[4]^, 0);
	if (xk > 678) and (xk < 868) and (yk > 463) and (yk < 653) then
		putimage(500, 404, bmp[6]^, 0);
		
	//delay(10);

end;

procedure GAME;
var
	dx, dy, direction, pre_direction, lifetime, sp1, sp2, sc1: integer;
	po, length_b, speed1_b, speed2_b: boolean;
const
	head_i = 15;
	head_j = 15;	

	
			{ОТРИСОВКА}
	procedure mas_ris_pole;
	var 
		i, j: integer;
		chis, add, length: string;
		
	begin
		cleardevice;
		putimage(0, 0, bmp[13]^, 0);
		putimage(664, 0, bmp[11]^, 0);
		
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
						putanim(j * 20 + 30, i * 20 + 30, sn[5], transput);
						

					if (pole[i, j] = 1) and (dx = 1) and (dy = 0) then
						putanim(j * 20 + 30, i * 20 + 30, sn[5], transput);
					if (pole[i, j] = 1) and (dx = -1) and (dy = 0) then
						putanim(j * 20 + 30, i * 20 + 30, sn[6], transput);
					if (pole[i, j] = 1) and (dx = 0) and (dy = -1) then
						putanim(j * 20 + 30, i * 20 + 30, sn[4], transput);
					if (pole[i, j] = 1) and (dx = 0) and (dy = 1) then
						putanim(j * 20 + 30, i * 20 + 30, sn[3], transput);	
						
					if (pole[i, j] = -1) then
						putimage(j * 20 + 30, i * 20 + 30, bmp[1], 0);					
					
				if (pole[i, j] = -3) then
						putanim(j * 20 + 30, i * 20 + 30, mas_boost[6], transput);
						
					if (pole[i, j] = 4) then
						putanim(j * 20 + 30, i * 20 + 30, sn[9], transput);
					if (pole[i, j] = 7) then
						putanim(j * 20 + 30, i * 20 + 30, sn[12], transput);
					if (pole[i, j] = 5) then
						putanim(j * 20 + 30, i * 20 + 30, sn[10], transput);
					if (pole[i, j] = 6) then
						putanim(j * 20 + 30, i * 20 + 30, sn[11], transput);
					if (pole[i, j] = 6) then
						putanim(j * 20 + 30, i * 20 + 30, sn[11], transput);
					if (pole[i, j] = 7) then
						putanim(j * 20 + 30, i * 20 + 30, sn[12], transput);					
					if (pole[i, j] = 5) then
						putanim(j * 20 + 30, i * 20 + 30, sn[10], transput);
					if (pole[i, j] = 4) then
						putanim(j * 20 + 30, i * 20 + 30, sn[9], transput);
						
					if (pole[i, j] = 2) then
						putanim(j * 20 + 30, i * 20 + 30, sn[7], transput);
					if (pole[i, j] = 2) then
						putanim(j * 20 + 30, i * 20 + 30, sn[7], transput);
					if (pole[i, j] = 3) then
						putanim(j * 20 + 30, i * 20 + 30, sn[8], transput);
					if (pole[i, j] = 3) then
						putanim(j * 20 + 30, i * 20 + 30, sn[8], transput);
						
					
					if (pole[i, j] = 10) then
						putanim(j * 20 + 25, i * 20 + 30, mas_boost[1], transput);
					if (pole[i, j] = 11) then
						putanim(j * 20 + 25, i * 20 + 30, mas_boost[2], transput);
					if (pole[i, j] = 12) then
						putanim(j * 20 + 25, i * 20 + 30, mas_boost[3], transput);
					if (pole[i, j] = 13) then
						putanim(j * 20 + 25, i * 20 + 30, mas_boost[4], transput);
					if (pole[i, j] = 14) then
						putanim(j * 20 + 25, i * 20 + 30, mas_boost[10], transput);
					
					
					if pole[i, j] = 8 then
					begin	
						case q of 
							1: putanim(j * 20 + 25, i * 20 + 25, planet[1], transput);
							2: putanim(j * 20 + 25, i * 20 + 25, planet[2], transput);
							3: putanim(j * 20 + 25, i * 20 + 25, planet[3], transput);
							4: putanim(j * 20 + 25, i * 20 + 25, planet[4], transput);
							5: putanim(j * 20 + 25, i * 20 + 25, planet[5], transput);
							6: putanim(j * 20 + 25, i * 20 + 25, planet[6], transput);
						end;
					end;	
				end;
			
				for i := 1 to k_bl - 1 do
				begin
					putanim(ast[i, 1] * 20 + 30, ast[i, 10] * 20 + 30, sn[1], transput);
					str(ast[i, 19], chis);
					settextstyle(8, 0, 40);
					outtextxy(ast[i, 1] * 20 + 30, ast[i, 10] * 20 + 30, chis);
				end;
				
				
			if speed1_b then
				putanim(755, 530, mas_boost[7], transput);
			if speed2_b then
				putanim(755, 530, mas_boost[8], transput);
			if length_b then
				putanim(755, 530, mas_boost[9], transput);	
				
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
				putanim(640 + i * 70, 450, mas_boost[5], transput);


		
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
		q := random(6) + 1; 
		writeln(q);
	end;
	
	procedure appear_boost;
	var 
		i_b, j_b: integer;
	begin	
		repeat
			j_b := random(30) + 1;
			i_b := random(30) + 1;
		until (pole[i_b, j_b] = 0) and (pole[i_b, j_b] <> -1) and (pole[i_b, j_b] <> 9) or (closegraphrequest);
		
		if lifetime = 3 then 
		repeat
			pole[i_b, j_b] := random(5) + 10
		until pole[i_b, j_b] <> 13
		else pole[i_b, j_b] := random(5) + 10;

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
	

	procedure shop;
	var
		inis: TINIFile;
		procedure ris_shop;
		begin
			cleardevice;
			CheckMouse;
			xk := GetMouseX;
			yk := GetMouseY;
			putimage(0, 0, bmp[32]^, 0);
			putimage(250, 0, bmp[33]^, 0);
			putimage(450, 0, bmp[34]^, 0);
			putimage(671, 0, bmp[35]^, 0);
			putimage(0, 250, bmp[36]^, 0);
			putimage(250, 250, bmp[37]^, 0);
			putimage(450, 250, bmp[38]^, 0);
			putimage(671, 250, bmp[39]^, 0);
			putimage(0, 450, bmp[40]^, 0);
			
			{if (xk > 100) and (xk < 317) and (yk > 546) and (yk < 648) and (click) then
				
			if (xk > 368) and (xk < 585) and (yk > 546) and (yk < 648) and (click) then
				
			if (xk > 635) and (xk < 852) and (yk > 546) and (yk < 648) and (click) then
}
		end;
	begin
		inis := TINIFile.create('TOP.ini');
		sp1 := ini.readInteger('shop', 'sp1', 0);
		sp2 := ini.readInteger('shop', 'sp2', 0);
		sc1 := ini.readInteger('shop', 'sc1', 0);
		
		
	repeat
		click := false;
		ris_shop;
		updategraph(updatenow);
		CheckMouse;
		xk := GetMouseX;
		yk := GetMouseY;
		{if (xk > 100) and (xk < 317) and (yk > 546) and (yk < 648) and (click) then
			
		if (xk > 368) and (xk < 585) and (yk > 546) and (yk < 648) and (click) then
			
		if (xk > 635) and (xk < 852) and (yk > 546) and (yk < 648) and (click) then
		}	
		delay(10);

		
	until (ch = space) or (closegraphrequest);
		
		
		
	end;
	
	
			{ПРОЦЕДУРА ДВИЖЕНИЯ ЗМЕЙКИ}
	procedure move;
	var 
		speed, sp, time, time_bl, time_boost, step, ran, k, z, l, sco, ti: integer;
		stol, lose, eat, eat_boost, step_bool, ch_nap, ch_st_stp: boolean;
			
			
			procedure level1(fn: string);
			var 
				i, j, a: integer;
				c: string;
				d: file of integer;
			begin
				assign(d, fn);
				a := 0;
				reset(d);
				for i := 1 to 30 do
					for j := 1 to 30 do
					begin
						read(d, a);
						//val(c, a);
						writeln(j, 'a = ',a);
						//pole[i, j] := a;
					end;
				close(d);
				k_bl := 0;

			end;

			
			
			procedure pause;			
			begin
				po := not(po);
				writeln(po);
				if po then 
					shop;
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
						pole[snake[t, 2], snake[t, 1]] := snake[t, 3]; 
					
			end;
	

			procedure init_characteristics;
			begin
				speed := sp;
				l := 1;
				sco := 1;
				
				speed1_b := false;
				speed2_b := false;
				length_b := false;
				
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
		ti := 20;
		sco := 1;
		sp1 := 30;
		sp2 := 5;
		sc1 := 10;
		dx := 0;
		dy := 0;
		step := 0;
		time := 0;
		time_bl := 0;
		time_boost := 0;
		direction := 0;
		speed := 15;
		sp := 15;
		step_bool := false;
		lose := false;
		eat := false;
		stol := false;
		eat_boost := false;
		speed1_b := false;
		speed2_b := false;
		length_b := false;
		
		repeat
		
		if po = false then 
		begin
		
		
				if keypressed and (ch_nap = false) then
				begin {считывание направления}
					ch := readkey;
					if ch = #0 then ch := readkey;
					case ch of
						up{1}: 
						begin 
							if direction <> 2 then
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
								
								ch_nap := true;
							end;
							
						end;
						down{2}: 
						begin 
						if direction <> 1 then
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
								ch_nap := true;							
							end;
						end;
						right{3}: 
						begin 
						if direction <> 4 then
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
								ch_nap := true;
							end;	
						end;
						left{4}: 
						begin 
						if direction <> 3 then
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
								
								ch_nap := true;
							end;
						end;
						space: pause;
					end;
				end;
				
				if time = speed then
				begin {изменение положения}
						
					if  (pole[snake[1, 2] + dy, snake[1, 1] + dx] = -1) then 
						dec_lifetime
					else
					
					begin
							
						if eat then
						begin
							if time_bl = ti then 
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
										begin
										ch_st_stp := ch_nap;
										stol := true;
										end;
								if stol then
								begin
						

						//ch_nap := false;
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
											inc(score, sco);
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
											stol := false;
											ch_nap := ch_st_stp;
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
							speed := sp1;
							pole[snake[1, 2] + dy, snake[1, 1] + dx] := 0;
							eat_boost := true;
							step_bool := true;
							speed1_b := true;
							step := 0;
							//writeln(eat_boost);
						end;	

						if pole[snake[1, 2] + dy, snake[1, 1] + dx] = 11 then
						begin
							speed := sp2;
							pole[snake[1, 2] + dy, snake[1, 1] + dx] := 0;
							eat_boost := true;
							step_bool := true;
							speed2_b := true;
							step := 0;
							//writeln(eat_boost);
						end;	
						
						
						if pole[snake[1, 2] + dy, snake[1, 1] + dx] = 12 then
						begin
							l := 0;
							pole[snake[1, 2] + dy, snake[1, 1] + dx] := 0;
							eat_boost := true;
							step_bool := true;
							length_b := true;
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
						end;	

						if pole[snake[1, 2] + dy, snake[1, 1] + dx] = 14 then
						begin
							sco := sc1;
							pole[snake[1, 2] + dy, snake[1, 1] + dx] := 0;
							eat_boost := true;
							step_bool := true;
							step := 0;
						end;	
						
						
						if step >= 300 then 
						begin
							init_characteristics;
							//delay(100);
						end;
				END;		
				

						
						if pole[snake[1, 2] + dy, snake[1, 1] + dx] <> 9 then
						begin
							
							for i := len downto 2 do
							begin	
								snake[i, 1] := snake[i - 1, 1];
								snake[i, 2] := snake[i - 1, 2];
								snake[i, 3] := snake[i - 1, 3];
							end;
							
							for i := len to 600 do
							begin
								snake[i, 1] := snake[len, 1];
								snake[i, 2] := snake[len, 2];
								snake[i + 1, 3] := 0;
							end;
							
							snake[1, 1] := snake[1, 1] + dx;
							snake[1, 2] := snake[1, 2] + dy;
							
							
						if ch_nap then
						begin
						if( direction = 2 ) then
						begin if( pre_direction = 3) then
								snake[2,3] := 7
							else
							if( pre_direction = 4 ) then
								snake[2,3] := 6;
						end
						else						
						if( direction = 1 ) then
						begin if( pre_direction = 3) then
								snake[2,3] := 4
							else
							if( pre_direction = 4 ) then
								snake[2,3] := 5;
						end	
						else						
						if( direction = 4 ) then
						begin if( pre_direction = 1) then
								snake[2,3] := 7
							else
							if( pre_direction = 2 ) then
								snake[2,3] := 4;
						end				
						else						
						if( direction = 3 ) then
						begin if( pre_direction = 1) then
								snake[2,3] := 6
							else
							if( pre_direction = 2 ) then
								snake[2,3] := 5;
						end;
						end
						else if( (direction = 2) or (direction = 1)  ) then
								snake[2,3] := 2
							else
								snake[2,3] := 3;
		
						
						end;
						ch_nap := false;
		
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
						{for i := 0 to 31 do
						begin
							writeln;
							for j := 0 to 31 do
								write(pole[i, j], ' ');
						end;
						writeln;}
						END;
						
					end;
					time := 0;
				end;
					if step_bool = true then
					begin
						inc(step); 
						writeln(step);
						
					end;
				mas_ris_pole;
				delay(10);
				inc(time);
				
						case score of
							20..30: begin sp := 14; th := 11; ti := 19; end;
							40..50: begin sp := 13; th := 12; ti := 19; end;
							60..70: begin sp := 12; th := 14; ti := 18; end;
							80..90: begin sp := 11; th := 16; ti := 17; end;
							100..110: begin sp := 10; th := 17; ti := 16; end;
							150..160: begin sp := 9; th := 19; ti := 15; end;
							200..210: begin sp := 8; th := 20; ti := 14; end;
							250..260: begin sp := 7; th := 21; ti := 13; end;
							310..320: begin sp := 6; th := 24; ti := 13; end;
							400..410: begin sp := 5; th := 26; ti := 12; end;
							500..510: begin sp := 4; th := 28; ti := 11; end;
							650..660: begin sp := 3; th := 30; ti := 10; end;
						end;
						
				writeln('sp = ', sp, 'th = ', th, 'ti = ', ti);
		end;
			
				
		until (ch = esc) or (lifetime = 0) or (closegraphrequest);

		if ch = esc then 
			ex := true;
				writeln('ex = ', ex);
		if ex = false then TOP;
		
				for i := 1 to k_bl do
			ast[i, 19] := 0;
		end;
		

	procedure pr_exit;
	var 
		xk: integer;
		
		
		procedure ris_exit;
		var i, j: integer;

		begin 

				putimage(0, 0, bmp[7]^, 0);
				xk := GetMouseX;
				yk := GetMouseY;
				if (xk > 87) and (xk < 276) and (yk > 231) and (yk < 422) then
					putimage(0, 0, bmp[10]^, 0);
				if (xk > 356) and (xk < 546) and (yk > 395) and (yk < 556) then
					putimage(320, 363, bmp[8]^, 0);
				if (xk > 657) and (xk < 848) and (yk > 406) and (yk < 597) then
					putimage(611, 363, bmp[9]^, 0);
		updategraph(updatenow);		

		end;	

	begin
		
		cleardevice;
		xk := 600;	
		ris_exit;
		
	repeat
		click := false;
		flag := false;
		ris_exit;
		//updategraph(updatenow);
		CheckMouse;
		xk := GetMouseX;
		yk := GetMouseY;
		if (xk > 87) and (xk < 276) and (yk > 231) and (yk < 422) and (click) then
			TOP;
		if (xk > 356) and (xk < 546) and (yk > 395) and (yk < 556) and (click) then
			GAME;
		if (xk > 657) and (xk < 848) and (yk > 406) and (yk < 597) and (click) then
		begin
			putimage(0, 0, bmp[4]^, 0);
			flag := true;	
		end;
		delay(10);

		
	until (flag) or (closegraphrequest);		
		ris_menu; 	

		updategraph(updatenow);
	end;

	procedure initGame;
	var 
		i, j: integer;

	begin
		randomize;
		ch := '1';
		len := 1;
		n := 5;
		th := 10;
		score := 0;
		k_bl := 1;
		po := false;
		
		ini := TINIFile.create('TOP.ini');
		sp1 := ini.readInteger('shop', 'sp1', 0);
		sp2 := ini.readInteger('shop', 'sp2', 0);
		sc1 := ini.readInteger('shop', 'sc1', 0);
		
		
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
		
			{НАЧАЛЬНОЕ ПОЛОЖЕНИЕ ГОЛОВЫ ЗМЕЙКИ}
		pole[snake[1, 2], snake[1, 1]] := 1;
		
	end;



	
BEGIN
	cleardevice;
	setWindowSize(950,700);
	gd := nopalette;
	gm := mCustom;
	initgraph (gd, gm, '');	
	m := true;
	if ( m  = true ) then
		PlaySound('music\THE_HARDKISS_-_PiBiP_official_.wav', 0, SND_ASYNC);
	initGame;	
	move;	
	mes := true;
	if ( mes  = true ) then
		PlaySound('music\Ludovico_Einaudi_-_The_tower.wav', 0, SND_ASYNC);

	ris_menu;
	updategraph(updatenow);
	
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
    y, i, f_h: integer;
	men: boolean;
	
	procedure ris_help;
	var 
		i, j: integer;
		//ini1: TINIFile;

	begin
		putimage(0, 0, bmp[2]^, 0);
		if f_h = 1 then putimage(0, 496, bmp[20]^, 0);
		if f_h = 8 then putimage(609, 496, bmp[21]^, 0);
				delay(10);


		xk := GetMouseX;
		yk := GetMouseY;
		if (xk > 100) and (xk < 317) and (yk > 546) and (yk < 648) then
		begin
			if f_h = 1 then putimage(0, 496, bmp[20]^, 0)
			else putimage(0, 496, bmp[17]^, 0);
		end;
		if (xk > 368) and (xk < 585) and (yk > 546) and (yk < 648) then
			putimage(342, 496, bmp[18]^, 0);
		if (xk > 635) and (xk < 852) and (yk > 546) and (yk < 648) then
		begin
			if f_h = 8 then putimage(609, 496, bmp[21]^, 0)
			else putimage(609, 496, bmp[19]^, 0);
		end;
			
			case f_h of
				1: putimage(0, 0, bmp[24]^, 0);
				2: putimage(0, 0, bmp[25]^, 0);
				3: putimage(0, 0, bmp[26]^, 0);
				4: putimage(0, 0, bmp[27]^, 0);
				5: putimage(0, 0, bmp[28]^, 0);
				6: putimage(0, 0, bmp[29]^, 0);
				7: putimage(0, 0, bmp[30]^, 0);
				8: putimage(0, 0, bmp[31]^, 0);
			end;
		updategraph(updatenow);
			
	end;
	
  begin
    cleardevice;
	putimage(0, 0, bmp[2]^, 0);
    assign(f, fn);
    reset(f);
    y := 250;
	settextstyle(6, 0, 35);
	
	updategraph(updatenow);
	f_h := 1;
    
	repeat
		click := false;
		men := false;
		ris_help;
		updategraph(updatenow);
		CheckMouse;
		xk := GetMouseX;
		yk := GetMouseY;
		if (xk > 100) and (xk < 317) and (yk > 546) and (yk < 648) and (click) then
			if f_h = 1 then f_h := 1
			else dec(f_h);
		if (xk > 368) and (xk < 585) and (yk > 546) and (yk < 648) and (click) then
				men := true;
		if (xk > 635) and (xk < 852) and (yk > 546) and (yk < 648) and (click) then
			if f_h = 8 then f_h := 8
			else inc(f_h);
		delay(10);

		
	until (men) or (closegraphrequest);	
  end;
	


	
BEGIN
	ini := TINIFile.Create('TOP.ini');
	setWindowSize(950, 700);
	gd := nopalette;
	gm := mCustom;
	initgraph (gd, gm, ini.ReadString('title', 'title', ''));	
	init_MENU;
	ris_menu;
	updategraph(updateoff);
	mes := true;
	if ( mes  = true ) then
		PlaySound('music\Ludovico_Einaudi_-_The_tower.wav', 0, SND_ASYNC);
		delay(10);

	repeat
		click := false;
		ris_menu;
		updategraph(updatenow);
		CheckMouse;
		xk := GetMouseX;
		yk := GetMouseY;
		if (xk > 678) and (xk < 868) and (yk > 463) and (yk < 653) and (click) then
				exit;
		if (xk > 712) and (xk < 902) and (yk > 61) and (yk < 251) and (click) then
		begin
				GAME;
			
		end;
		if (xk > 47) and (xk < 230) and (yk > 186) and (yk < 368) and (click) then
				HELP('help.txt');
		if (xk > 112) and (xk < 298) and (yk > 486) and (yk < 669) and (click) then
				TOP;
		delay(10);

		
	until (closegraphrequest);		

	closegraph;
END.