program my;
uses wingraph,wincrt,winmouse,winevent,MMSystem,sysutils,windows;
type
bots = record
        x_bot,y_bot,dx_bot,dy_bot,hp_bot:integer;
        priznak_bot:boolean;
        end;
nlo_shots = record
        x_nlo_shots,y_nlo_shots,dx_nlo_shots,dy_nloshots,hp_nlo_shots:integer;
        priznak_nlo_shots:boolean;
        end;
enemy = record
        x_enemy,y_enemy,dx_enemy,dy_enemy,hp_enemy:integer;
        priznak:boolean;
        end;
meteorit = record
        x_meteor,y_meteor,dx_meteor,dy_meteor,hp_meteor,n:integer;
        priznak_meteor:boolean;
        end;
mas_nlo_shots=array[1..2]of nlo_shots;
mas_meteor=array[1..32]of meteorit;
mas_r=array[1..100]of integer;
mas_nlo1_shots_pulya=array[1..50]of integer;
mas_nlo2_shots_pulya=array[1..50]of integer;
mas_r_boss=array[1..200]of integer;
mas_r_boss2=array[1..200]of integer;
mas_enemy=array[1..32]of enemy;
Bot_heal=array[1..2]of bots;
heal_particle=array[1..20] of integer;
heal_2_particle=array[1..20] of integer;
var
t:string;
xBoss,yBoss,dx,dy_boss,boss_delay,boss2_delay:smallInt;
meteor_kos:mas_meteor;
enemy_rand,enemy_goriz:mas_enemy;
bot_healers:bot_heal;
nlo_shots_logarifmich:mas_nlo_shots;
ch:char;
x_heal_particle,y_heal_particle,dx_heal_particle:heal_particle;
x_heal_2_particle,y_heal_2_particle,dx_heal_2_particle:heal_2_particle;
x_nlo1_shots_pulya,y_nlo1_shots_pulya,dy_nlo1_shots_pulya:mas_nlo1_shots_pulya;
x_nlo2_shots_pulya,y_nlo2_shots_pulya,dy_nlo2_shots_pulya:mas_nlo2_shots_pulya;
x_r,y_r,dy_r:mas_r;
x_r_boss,y_r_boss,dy_r_boss,dx_r_boss,ugl_boss:mas_r_boss;
x_r_boss2,y_r_boss2,dy_r_boss2,dx_r_boss2,ugl_boss2:mas_r_boss2;
nlo1_shots_pusk:array[1..50]of boolean;
nlo2_shots_pusk:array[1..50]of boolean;
pusk:array[1..100]of boolean;
boss_pusk:array[1..200]of boolean;
boss2_pusk:array[1..200]of boolean;
healers_bot_pusk:array[1..20]of boolean;
healers_bot_2_pusk:array[1..20]of boolean;
flag,shot,next_lvl,priznak_boss,song1,song2:boolean;
HUD_initialization:boolean;
k,s,a,m_boss,m_boss2,m_nlo1_shots,m_nlo2_shots:smallint;
gd,gm,xCh,yCh,d,x,y,MyDelay,m,kolvo,dialog_pos,hp_boss,enemy_attack_delay:smallint;
ship,pulya,ship_enemy,ship_enemy_boss,pulya_red,pobeda,NLO_Shots_p,pulya_purple_small:pointer;
score,HP: smallint;
yellow_explosion:array[1..5]of pointer;
timeNow,timeAll:dword;
meteor : array[0..2]of pointer;
particle_heal:array[1..2]of pointer;

HUD_HP_1,HUD_HP_2,HUD_HP_3,HUD_HP_4:pointer;
HUD_LIFE:pointer;
HUD_FORCE:pointer;
HUD_LVLBAR_CLEAR,HUD_LVLBAR_1,HUD_LVLBAR_2,HUD_LVLBAR_3,HUD_LVLBAR_4:pointer;
HUD_SCORE:pointer;
HUD_HP_INIT,HUD_LVL_INIT:boolean;
hud_a,Hud_kolvo,Hud_s,H_score,score_1,z:integer;

picked_hero:integer;
hero_logo:array[1..3]of pointer;
act:boolean;


boss_explosion,boss_lazer_pusk,boss_delay_if_hp30:smallint;
boss_up:boolean;
Boss_lazer_vert,boss_pulya,Boss_lazer_horiz,Boss_rocket_vert,Boss_rocket_horiz,Boss_rocket_45_l,Boss_rocket_45_r,boss_plazma,boss_lazer_predupr:pointer;
bot_healer,bot_healer_r:pointer;
healer_bot_delay,healer_bot_m,healer_bot_2_m:smallint;

procedure menu; Forward;
procedure lvl_1; Forward;
procedure restart; Forward;
procedure dialog; Forward;
procedure MouseInit(var act:boolean); Forward;


procedure Timer;
begin

if timeall=0 then timeall:=gettickCount;
if timeNow=0 then timeNow:=gettickCount-timeall;
if timeNow>0 then
begin
timeall:=gettickCount;
sleep(12);
timeNow:=timeNow+(gettickcount-timeall);
end;
//writeln(timeNow);

end;

{proocedure runAsync(proc:procedure);
begin
var t:=new Thread(proc);
t.Start;
end;   }



procedure ChangeFont(size:smallint);
var font:smallint;
begin
  font:=InstallUserFont('Georgia');
  //font:=InstallUserFont('TRIP.CHR');
  if (font<0) then Exit;
  SetTextStyle(font,HorizDir,size);
end;

procedure ris(st:string;var p:pointer);
var
f:file;
sz:longint;
        begin
        assign(f,st);
        reset(f,1);
        sz:=filesize(f);
        getmem(p,sz);
        blockread(f,p^,sz);
        close(f);
        end;

procedure explosion(x,y,szx,szy:integer;gif:array of pointer);
var i,a:integer;
x1,y1,x2,y2:integer;
        begin
        x1:=x;
        x2:=szx;
        y1:=y;
        y2:=szy;
        a:=random(3);
        for i:=0 to 3 do
        begin
        if i=0 then begin
        putimage(x1+round(x2/2),y1+y2-32,gif[a]^,xorput);
        sleep(20);
        end;
        if i=3 then
         // sleep(1);
      //  delay(4);
        putimage(x1+round(x2/2),y1+y2-32,gif[a]^,xorput);
        end;
      //  delay(1);
        end;



procedure HUD(var a,s,score,kolvo,hp:integer;var HUD_INIT,flag:boolean);
var
i:integer;

begin
if HUD_init then
begin
HUD_HP_INIT:=true;
HUD_LVL_INIT:=true;
HUD_init:=false;
z:=1;
HUD_a:=a;

writeln(a);
//HUD_kolvo:=kolvo;
ris('HUD_HP_1.bmp',HUD_HP_1);
ris('HUD_HP_2.bmp',HUD_HP_2);
ris('HUD_HP_3.bmp',HUD_HP_3);
ris('HUD_HP_4.bmp',HUD_HP_4);

ris('HUD_LIFE.bmp',HUD_LIFE);

ris('HUD_FORCE.bmp',HUD_FORCE);

ris('HUD_SCORE.bmp',HUD_SCORE);

ris('HUD_LVLBAR_CLEAR.bmp',HUD_LVLBAR_CLEAR);
ris('HUD_LVLBAR_1.bmp',HUD_LVLBAR_1);
ris('HUD_LVLBAR_2.bmp',HUD_LVLBAR_2);
ris('HUD_LVLBAR_3.bmp',HUD_LVLBAR_3);
ris('HUD_LVLBAR_4.bmp',HUD_LVLBAR_4);
for i:=1 to hp do
putimage(i*36+26,60,HUD_LIFE^,XORPUT);
end;
{
if h_score=score then
begin
score_1:=score;
h_score:=-32767;
putimage(1,1,HUD_SCORE^,XORPUT);
writeln('fuck',score,h_score);

end; }
score_1:=score+1;
if score_1<>score then
begin
changefont(3);
score_1:=score;
putimage(1,1,HUD_SCORE^,Xorput);
setcolor(black);
setfillstyle(1,black);
bar(0,0,160,30);
bar(0,0,58,93);

setcolor(white);
if score<0 then score:=0;
outtextxy(55,-2,inttostr(score));
//sleep(1);
putimage(1,1,HUD_SCORE^,Xorput);
end;
//writeln(HUD_LIFE_NOW);


if (a=0)and(HUD_HP_INIT) then
begin
hud_hp_init:=false;
putimage(56,30,HUD_HP_4^,xorput);
//putimage(56,26,HUD_HP_4^,xorput);
end;
if (a=1)and(not HUD_HP_INIT)then
begin
hud_hp_init:=true;
putimage(56,30,HUD_HP_4^,xorput);
putimage(56,30,HUD_HP_3^,xorput);
end;
if (a=2)and(HUD_HP_INIT)then
begin
hud_hp_init:=false;
putimage(56,30,HUD_HP_3^,xorput);
putimage(56,30,HUD_HP_2^,xorput);
end;
if (a=3)and(not HUD_HP_INIT)then
begin
hud_hp_init:=true;
putimage(56,30,HUD_HP_2^,xorput);
putimage(56,30,HUD_HP_1^,xorput);
end;
if (a>=4)and(HUD_HP_INIT)then
begin
putimage(56,30,HUD_HP_1^,xorput);
a:=0;
HUD_HP_INIT:=true;
hp:=hp-1;
if hp=2 then
putimage(3*36+26,60,HUD_LIFE^,XORPUT);
if hp=1 then
putimage(2*36+26,60,HUD_LIFE^,XORPUT);
if hp=0 then
putimage(1*36+26,60,HUD_LIFE^,XORPUT);
//writeln(hp);
if hp<=-1 then flag:=false;
//putimage(56,30,HUD_HP_1^,xorput);
end;


if (s=0)and(HUD_LVL_INIT) then
begin
hud_lvl_init:=false;
putimage(56,90,HUD_lvlbar_4^,xorput);
//putimage(56,26,HUD_HP_4^,xorput);
end;
if (s=1)and(not HUD_LVL_INIT) then
begin
hud_lvl_init:=true;
putimage(56,90,HUD_lvlbar_4^,xorput);
putimage(56,90,HUD_lvlbar_3^,xorput);
end;
if (s=2)and(HUD_LVL_INIT) then
begin
hud_lvl_init:=false;
putimage(56,90,HUD_lvlbar_3^,xorput);
putimage(56,90,HUD_lvlbar_2^,xorput);
end;
if (s=3)and(not HUD_LVL_INIT) then
begin
hud_lvl_init:=true;
putimage(56,90,HUD_lvlbar_2^,xorput);
putimage(56,90,HUD_lvlbar_1^,xorput);
end;
if (s=4)and(HUD_LVL_INIT) then
begin
hud_lvl_init:=false;
putimage(56,90,HUD_lvlbar_1^,xorput);
putimage(56,90,HUD_lvlbar_CLEAR^,xorput);
end;
end;





procedure hero_chose(var act:boolean);
var
a:smallint;
text:pointer;
panel:array[1..3]of pointer;
panel_pick:array[1..3]of pointer;
mouse_on_panel:array[1..3] of boolean;
begin
cleardevice;
ris('Chose hero.bmp',text);
ris('Hero.bmp',hero_logo[1]);
ris('Hero_2_Girl.bmp',hero_logo[2]);
ris('Hero_3_Alien.bmp',hero_logo[3]);
ris('panel_blue.bmp',panel[1]);
ris('panel_red.bmp',panel[2]);
ris('panel_green.bmp',panel[3]);
ris('panel_blue_pick.bmp',panel_pick[1]);
ris('panel_red_pick.bmp',panel_pick[2]);
ris('panel_green_pick.bmp',panel_pick[3]);
putimage(344,0,text^,xorput);
putimage(186,150,hero_logo[1]^,xorput);
putimage(565,150,hero_logo[2]^,xorput);
putimage(944,150,hero_logo[3]^,xorput);
putimage(164,380,panel[1]^,xorput);
putimage(543,380,panel[3]^,xorput);
putimage(922,380,panel[2]^,xorput);
repeat
timer;
act:=false;
mouseinit(act);
if (getmousex>=166)and(getmousex<=399)and(mouse_on_panel[1]=true)and(getmousey>=380)and(getmousey<=688)then
        begin
        putimage(164,380,panel[1]^,xorput);
        putimage(164,380,panel_pick[1]^,xorput);
        mouse_on_panel[1]:=false;
        mouseinit(act);
       // writeln(act);
        if act=true then begin picked_hero:=1;  dialog; end;
        end
        else
        if (mouse_on_panel[1]=false)and(not((getmousex>=166)and(getmousex<=399)and(getmousey>=380)and(getmousey<=688))) then
        begin


        putimage(164,380,panel_pick[1]^,xorput);
        putimage(164,380,panel[1]^,xorput);
        mouse_on_panel[1]:=true;
        end;


if (getmousex>=543)and(getmousex<=766)and(mouse_on_panel[3]=true)and(getmousey>=380)and(getmousey<=688)then
        begin
        putimage(543,380,panel[3]^,xorput);
        putimage(543,380,panel_pick[3]^,xorput);
        mouse_on_panel[3]:=false;
        mouseinit(act);
       // writeln(act);
        if act=true then begin picked_hero:=2;  dialog; end;
        end
        else
        if (mouse_on_panel[3]=false)and(not((getmousex>=543)and(getmousex<=766)and(getmousey>=380)and(getmousey<=688))) then
        begin


        putimage(543,380,panel_pick[3]^,xorput);
        putimage(543,380,panel[3]^,xorput);
        mouse_on_panel[3]:=true;
        end;

if (getmousex>=922)and(getmousex<=1155)and(mouse_on_panel[2]=true)and(getmousey>=380)and(getmousey<=688)then
        begin
        putimage(922,380,panel[2]^,xorput);
        putimage(922,380,panel_pick[2]^,xorput);
        mouse_on_panel[2]:=false;
        mouseinit(act);
       // writeln(act);
        if act=true then begin picked_hero:=3;  dialog; end;
        end
        else
        if (mouse_on_panel[2]=false)and(not((getmousex>=922)and(getmousex<=1155)and(getmousey>=380)and(getmousey<=688))) then
        begin


        putimage(922,380,panel_pick[2]^,xorput);
        putimage(922,380,panel[2]^,xorput);
        mouse_on_panel[2]:=true;
        end;




if keypressed then
begin
ch:=readkey;
if ch=#0 then ch:=readkey;
end;

until (ch=#27)or(closegraphrequest);
ch:=#0;
dialog;
end;




procedure polet_down(var x,y:integer;dy:integer;var bb:boolean;p:pointer);
begin
putimage(x,y,p^,xorput);
y:=y+dy;
if y+32<800 then bb:=false;
putimage(x,y,p^,xorput);
end;
procedure polet_boss_pulya(var x,y:integer;dy,dx:integer;var bb:boolean;p:pointer);
begin
putimage(x,y,p^,xorput);
y:=y+dy;
x:=x+dx;
if (y+32>800)or(y<0) then begin putimage(x,y,p^,xorput); bb:=true; end;
if (x+dx>1366)or(x-dx<0) then begin putimage(x,y,p^,xorput); bb:=true; end;
putimage(x,y,p^,xorput);
end;
procedure polet_boss_plazma(var x,y:integer;dy,dx:integer;var ugl:integer;var bb:boolean;p:pointer);
var x0,y0,x1,y1:integer; t:real;
begin
putimage(x,y,p^,xorput);

//writeln(inttostr(round((y+32)+45*sin(ugl*pi/180))));
y:=y+dy;
x:=x+dx;
//ugl:=ugl+1;
if (y+32>800)or(y<0) then begin putimage(x,y,p^,xorput); bb:=true; end;
if (x+dx>1366)or(x-dx<0) then begin putimage(x,y,p^,xorput); bb:=true; end;
putimage(x,y,p^,xorput);
end;

procedure polet(var x,y:integer;dy:integer;var bb:boolean;p:pointer);
begin
putimage(x,y,p^,xorput);
y:=y-dy;
if y+32<0 then bb:=false;
putimage(x,y,p^,xorput);
end;

procedure polet_boss(var x,y:integer;dy:integer;var bb:boolean;p:pointer);
begin
putimage(x,y,p^,xorput);
y:=y+dy;
if y+32>900 then bb:=false;
putimage(x,y,p^,xorput);
        end;


procedure neupr_logarifmich(var x,y:smallint;dx:integer;p:pointer);
var a,b,i:integer;

begin
        a:=a+10;
        putimage(x,y,p^,xorput);
        if dx>0 then
        begin
        x:=(x+dx);
        if x>=1300 then x:=1;
        y:=round(ln(x)*ln(x)*ln(x));
        end
        else
        begin
        if x<=7 then x:=1250;
        x:=(x+dx);
        y:=round(ln(x)*ln(x)*ln(x));
        end;

        putimage(x,y,p^,xorput);
end;



procedure neupr_goriz(var x,y:integer;dx:integer;p:pointer);
begin
        putimage(x,y,p^,xorput);
        x:=x+dx;
        if (x<0)or(x>getmaxx-128) then
        dx:=-dx;
        putimage(x,y,p^,xorput);
end;
procedure neupr_down(var x,y,dy:integer;p:pointer);
begin
        putimage(x,y,p^,xorput);
        y:=y+dy;
        putimage(x,y,p^,xorput);
        if Y>=768-128 then
        begin
        putimage(x,y,p^,xorput);
        x:=random(1366-128);
        y:=0-100;
        putimage(x,y,p^,xorput);
        end;
end;

procedure neupr_kos(var x,y,dy,dx:integer;p:pointer);
var i:integer;
begin
        putimage(x,y,p^,xorput);
       // dy:=random(dy)+1;
       // dx:=random(dx)+1;
        x:=x+dx;
        y:=y+dy;
        putimage(x,y,p^,xorput);
        if Y>=768 then
        begin
        kolvo:=kolvo+1;
        putimage(x,y,p^,xorput);
        x:=random(1366+128)+724;
        y:=random(128)-300;
        putimage(x,y,p^,xorput);
        end;
        if X>=1366+256 then
        begin
        kolvo:=kolvo+1;
        putimage(x,y,p^,xorput);
        x:=random(1366+128)+724;
        y:=random(128)-300;
        putimage(x,y,p^,xorput);
        end;
end;


procedure neupr_rand(var x,y:integer;dx,dy:integer;p:pointer);
var r:integer;
begin
 putimage(x,y,p^,xorput);
 r:=random(4)+1;
 case r of
 1:if (x<=1366-dx-128)then x:=x+dx;
 2:if (y>=dy) then y:=y-dy;
 3:if (x>=dx) then x:=x-dx;
 4:if (y<=768-dy-70)then y:=y+dy;
 end;
 putimage(x,y,p^,xorput);
end;

function proverka(x1,y1,dx,dy,x2,y2,dx2,dy2:integer):boolean;
begin
if (abs(x1-x2)<dx)and(abs(y1-y2)<dy)then
proverka:=true
else
proverka:=false;
end;

procedure MouseInit(var act:boolean);
var me,now:MouseEventType; i:smallint;
begin
writeln(act);
//act:=false;
i:=0;
  if not(PollMouseEvent(me)) then Exit;
  GetMouseEvent(me);
  with me do
  case action of
 MouseActionDown: begin

                        // writeln(({boolean}(mouseleftbutton){=false}),' | ',({boolean}(mouseactiondown)));//mouse button pressed//mouse button pressed
                       case buttons of
                     MouseRightButton : flag:=false;
                     MouseLeftButton: begin
                    //  writeln(act);
                   //  writeln((boolean(mouseleftbutton){=false}),' | ',(boolean(mouseactiondown)));
                     repeat
                     act:=true;
                       // writeln(getmousex,'  ',getmousey);
                       if (m<=100)and(Mydelay>=6) then
                         begin
                         x_r[m]:=xCh+54;
                         y_r[m]:=yCh;
                         putimage(x_r[m],y_r[m],pulya^,xorput);
                         pusk[m]:=true;
                         M:=m+1;
                         mydelay:=0;
                         if m=100 then m:=1;
                         end;

                        //  pulya_fly(pulya);

                     //  writeln(smallint(getmousex),' | ',smallint(getmousey));
                       //end;
                     //   delay(40);

                        until  boolean(MouseActionUp);
                        act:=false;//  <your code here>
                                          end;
                    //     <...>
                       end;
                     end;
 MouseActionMove:  begin


                       case buttons of
                     MouseRightButton : flag:=true;
                      MouseLeftButton:   begin
                        writeln(act);
                        // act:=false;
                         repeat
                          act:=true;
                       // if mydelay>=20 then

                         if (m<=100)and(Mydelay>=6) then
                         begin
                         x_r[m]:=xCh+54;
                         y_r[m]:=yCh;
                         putimage(x_r[m],y_r[m],pulya^,xorput);
                         pusk[m]:=true;
                         M:=m+1;
                         mydelay:=0;
                         if m=100 then m:=1;
                         end;

                                                 // circle(smallint(getmousex),smallint(getmousey),d);//Left button
                      //  delay(40);

                        until boolean(MouseActionUp);

                        end;//  <your code here>
                                          end;
                    //     <...>
                       end;
  //  <...>
       end;
end;



procedure init;

begin
ris('Boss_plazma.bmp',boss_pulya);
ris('Boss_lazer_vert.bmp',boss_lazer_vert);
ris('Boss_lazer_pusk.bmp',boss_lazer_predupr);
ris('NLO.bmp',ship_enemy);
ris('NLO_BOSS.bmp',ship_enemy_boss);
ris('pulya.bmp',pulya);
ris('space_ship.bmp',ship);
ris('NLO_Shots.bmp',NLO_Shots_p);
ris('pulya_red.bmp',pulya_red);
ris('boss_plazma.bmp',boss_plazma);
ris('pulya_purple_smal.bmp',pulya_purple_small);
ris('yellow_explosion_1.bmp',yellow_explosion[1]);
ris('yellow_explosion_2.bmp',yellow_explosion[2]);
ris('yellow_explosion_3.bmp',yellow_explosion[3]);
ris('yellow_explosion_4.bmp',yellow_explosion[4]);
ris('BOT_HEALER.bmp',bot_healer);
ris('BOT_HEALER_RIGHT.bmp',bot_healer_r);

xCh:=smallint(getmousex);
yCh:=680;
flag:=true;
m_nlo1_shots:=1;
m_nlo2_shots:=1;
d:=32;
boss_delay_if_hp30:=0;
shot:=false;
dialog_pos:=0;
for k:=1 to 100 do
begin
dy_r[k]:=24;
pusk[k]:=false;
m:=1;
m_boss:=1;
end;
for k:=1 to 2 do
begin
with nlo_shots_logarifmich[k]do
if k=1 then
        begin
        x_NLO_SHOTS:=1;
        y_NLO_SHOTS:=1;
        dx_NLO_SHOTS:=7;
        putimage(x_NLO_SHOTS,Y_NLO_SHOTS,NLO_SHOTS_P^,xorput);
        priznak_NLO_SHOTS:=true;
        hp_NLO_SHOTS:=8;
        end
        else

        begin
        x_NLO_SHOTS:=1250;
        y_NLO_SHOTS:=1;
        dx_NLO_SHOTS:=-7;
        putimage(x_NLO_SHOTS,Y_NLO_SHOTS,NLO_SHOTS_P^,xorput);
        priznak_NLO_SHOTS:=true;
        hp_NLO_SHOTS:=15;
        end;
        end;
for k:=1 to 20 do
begin
        with enemy_rand[k]do
        begin
        x_enemy:=random(1366-128);
        y_enemy:=random(20)-300;
        repeat

       // dx_enemy:=-8+random(14);
         putimage(x_enemy,y_enemy,ship_enemy^,xorput);
        dy_enemy:=random(20)+5;

        until dy_enemy<>0;

        priznak:=true;
        hp_enemy:=1+random(3);
        end;


       { with enemy_goriz[k]do
        begin
        x_enemy:=random(getmaxx-128);
        y_enemy:=random(getmaxy-256);                  2
        dy_enemy:=0;
        repeat
        dx_enemy:=-8+random(16);
        until dx_enemy<>0;
        putimage(x_enemy,y_enemy,ship_enemy^,xorput);
        priznak:=true;
        end;}
end;


end;

procedure win;
var n:integer;
begin
cleardevice;
changefont(100);
outtextxy(450,250,'You win!!!');
changefont(70);
outtextxy(480,380,'Score: '+Inttostr(score));
changefont(27);
outtextxy(1200,730,'Press Esc');
REPEAT
timer;
n:=random(26)+1;
case n of
1:putPIXEL(random(1366),random(768),red);
2:putPIXEL(random(1366),random(768),blue);
3:putPIXEL(random(1366),random(768),green);
4:putPIXEL(random(1366),random(768),yellow);
5:putPIXEL(random(1366),random(768),brightgreen);
6:putPIXEL(random(1366),random(768),vermilion);
7:putPIXEL(random(1366),random(768),bronze);
9:putPIXEL(random(1366),random(768),rust);
10:putPIXEL(random(1366),random(768),azure);
11:putPIXEL(random(1366),random(768),darkbrown);
12:putPIXEL(random(1366),random(768),teal);
13:putPIXEL(random(1366),random(768),black);
14:putPIXEL(random(1366),random(768),black);
15:putPIXEL(random(1366),random(768),black);
16:putPIXEL(random(1366),random(768),black);
17:putPIXEL(random(1366),random(768),black);
18:putPIXEL(random(1366),random(768),black);
19:putPIXEL(random(1366),random(768),black);
20:putPIXEL(random(1366),random(768),black);
21:putPIXEL(random(1366),random(768),black);
22:putPIXEL(random(1366),random(768),black);
23:putPIXEL(random(1366),random(768),black);
24:putPIXEL(random(1366),random(768),black);
25:putPIXEL(random(1366),random(768),black);
26:putPIXEL(random(1366),random(768),black);
end;

//delay(1);
if (keypressed)then
       begin
        ch:=readkey;
        if ch=#0 then ch:=readkey;
        end;
until (ch=#27);
ch:=#0;
menu;
end;

procedure init_3;
begin
cleardevice;
if song2 then
begin
sndPlaySound('C:\fpc\3.0.4\bin\i386-win32\blue.wav', snd_Async or snd_NoDefault);
song2:=false;
end;
dy_r[k]:=24;
pusk[k]:=false;
xBoss:=686-494;
yBoss:=0;
boss_up:=false;
hp_boss:=220;
priznak_boss:=true;
boss_delay:=0;
boss2_delay:=0;
boss_lazer_pusk:=0;
dx:=25;
dy_boss:=5;
m_boss2:=1;
healer_bot_m:=1;
healer_bot_delay:=0;
healer_bot_2_m:=1;
ris('PARTICLE_HEAL.bmp',particle_heal[1]);
ris('PARTICLE_HEAL_2.bmp',particle_heal[2]);
for k:=1 to 20 do
        begin
        healers_bot_pusk[k]:=true;
        end;
for k:=1 to 20 do
        begin
        healers_bot_2_pusk[k]:=true;
        end;
for k:=1 to 200 do
        begin
       // dy_r_boss[k]:=10;
        boss_pusk[k]:=true;
        end;
for k:=1 to 200 do
        begin
       // dy_r_boss[k]:=10;
        boss2_pusk[k]:=true;
        end;

for k:=1 to 2 do

    with bot_healers[k] do    {x_bot,y_bot,dx_bot,dy_bot,hp_bot:integer;
                            priznak_bot:boolean;}
    begin
    hp_bot:=20;
    priznak_bot:=false;
    end;

end;






procedure lvl_3;
var i,j,r:integer;

begin
cleardevice;
init_3;
a:=0;
next_lvl:=false;
putimage(xCh,yCh,ship^,xorput);
putimage(xBoss,yBoss,ship_enemy_boss^,xorput);
setmousexy(600,700);
repeat
boss_lazer_pusk:=boss_lazer_pusk+1;
boss_explosion:=boss_explosion+1;
healer_bot_delay:=healer_bot_delay+1;
boss_delay:=boss_delay+1;
boss2_delay:=boss2_delay+1;
MyDelay:=MyDelay+1;
timer;
HUD(a,s,score,kolvo,HP,HUD_initialization,flag);
begin
//changefont(20);
//settextstyle(CourierNewFont,0,40);
outtextxy(600,2,'HP Boss: '+inttostr(hp_boss));
setcolor(black);
setfillstyle(1,black);
bar(600,2,800,25);
setcolor(white);
outtextxy(600,2,'HP Boss: '+inttostr(hp_boss));
end;
putimage(xCh,yCh,ship^,xorput);
xCh:=smallint(getmousex);
yCh:=smallint(getmousey);
if yCh<=180 then yCh:=180;
if yCh>=766-64 then yCh:=766-64;
if xCh>=1366-128 then xCh:=1366-128;

putimage(xCh,yCh,ship^,xorput);
if proverka(xboss+220,yboss+100,274,202,xCh,yCh,64,64) then
begin
flag:=false;
end;


if priznak_boss=true then
begin
for i:=1 to 2 do
with bot_healers[k] do
        if (hp_boss<=30)and(priznak_bot=false)and(hp_bot>0)then
        begin

        for k:=1 to 2 do
        with bot_healers[k] do
                begin
                if k=1 then
                        begin
                        x_bot:=xboss-100;
                        y_bot:=yboss+150;
                        priznak_bot:=true;
                        dx_bot:=-10;
                        putimage(x_bot,y_bot,bot_healer_r^,xorput);
                        end
                else
                        begin
                        x_bot:=xboss+400;
                        y_bot:=yboss+150;
                        dx_bot:=10;
                        priznak_bot:=true;
                         putimage(x_bot,y_bot,bot_healer^,xorput);
                        end;
                end;
        end;


        if (boss_lazer_pusk>=100)and(hp_boss<=160)and(hp_boss>=101) then
        begin
        if boss_lazer_pusk>=200 then boss_lazer_pusk:=0;
        if ((boss_lazer_pusk-100) mod 20= 0){or(boss_lazer_pusk=120)or(boss_lazer_pusk=140)or(boss_lazer_pusk=160)}then
                begin
                putimage(xboss+230,yboss+298,boss_lazer_predupr^,xorput);
                 if proverka(xboss+230,yboss+298,64,768,xCh+40,yCh+64,1,1) then
                         begin
                         //  putimage(x_r_boss[i],y_r_boss[i],boss_plazma^,xorput);
                        //   boss_pusk[i]:=true;
                           explosion(xCh+40,yCh+64,128,64,yellow_explosion);
                        // a:=a-1;
                     // hp:=hp-1;
                        a:=a+2;
                        score:=score-140;
                        if a>4 then flag:=false;
                         end;
                sleep(150);
                putimage(xboss+230,yboss+298,boss_lazer_predupr^,xorput);
                end;
        end;


        if (m_boss<=200)and(boss_delay>=4)and(boss_pusk[m_boss]) then
        if (m_boss mod 2 = 0) then
                         begin
                         boss_delay:=0;
                         x_r_boss[m_boss]:=xboss+77;
                         y_r_boss[m_boss]:=yboss+282;
                         dy_r_boss[m_boss]:=8;
                         dx_r_boss[m_boss]:=random(3)-random(6);
                         putimage( x_r_boss[m_boss],y_r_boss[m_boss],pulya_purple_small^,xorput);
                         boss_pusk[m_boss]:=false;
                         M_boss:=m_boss+1;
                        // enemy_attack_delay:=0;
                         if m_boss=200 then m_boss:=1;
                         end//;
                         else
                          if hp_boss<=180 then
                         begin


                         boss_delay:=0;
                         x_r_boss[m_boss]:=xboss+77;
                         y_r_boss[m_boss]:=yboss+282;
                         dy_r_boss[m_boss]:=12;
                         dx_r_boss[m_boss]:=random(6)-random(12);
                         putimage( x_r_boss[m_boss],y_r_boss[m_boss],boss_plazma^,xorput);
                         boss_pusk[m_boss]:=false;
                         ugl_boss[m_boss]:=1;
                         M_boss:=m_boss+1;
                        // enemy_attack_delay:=0;
                         if m_boss>=200 then m_boss:=1;
                         end
                         else m_boss:=m_boss+1;  if m_boss>=200 then m_boss:=1;//;m_boss:=m_boss+1;
                        // if m_boss=100 then m_boss:=1;
if (m_boss2<=200)and(boss2_delay>=4)and(boss_pusk[m_boss]) then
        if (m_boss2 mod 2 = 0) then
                         begin
                         boss2_delay:=0;
                         x_r_boss2[m_boss2]:=xboss+350;
                         y_r_boss2[m_boss2]:=yboss+282;
                         dy_r_boss2[m_boss2]:=8;
                         dx_r_boss2[m_boss2]:=random(6)+random(6);
                         putimage( x_r_boss2[m_boss2],y_r_boss2[m_boss2],pulya_purple_small^,xorput);
                         boss2_pusk[m_boss2]:=false;
                         M_boss2:=m_boss2+1;
                        // enemy_attack_delay:=0;
                         if m_boss2>=200 then m_boss2:=1;
                         end//;
                         else
                          if hp_boss<=180 then
                         begin


                         boss2_delay:=0;
                         x_r_boss2[m_boss2]:=xboss+350;
                         y_r_boss2[m_boss2]:=yboss+282;
                         dy_r_boss2[m_boss2]:=12;
                         dx_r_boss2[m_boss2]:=random(6)+random(12);
                         putimage( x_r_boss2[m_boss2],y_r_boss2[m_boss2],boss_plazma^,xorput);
                         boss2_pusk[m_boss2]:=false;
                         ugl_boss2[m_boss2]:=1;
                         M_boss2:=m_boss2+1;
                         end
                         else m_boss2:=m_boss2+1;
                         if m_boss2>=200 then m_boss2:=1;
 putimage(xBoss,yBoss,ship_enemy_boss^,xorput);
        if hp_boss>=100 then begin
        xBoss:=Xboss+dx;
      //  yboss:=(yBoss+2);
        if yboss>=768 then yboss:=-80;
        if xBoss>=1366-494 then dx:=-dx;
        if xBoss<=0 then dx:=-dx;
        end;
        if hp_boss<100 then
        if boss_up then
        begin

        if boss_explosion>=8 then begin
        explosion(xboss,yboss,random(400),random(300),yellow_explosion);     boss_explosion:=0; end;
        yboss:=yboss-4;
        xboss:=xboss-random(dx)+random(dx);
        if yboss=20 then boss_up:=false;
        end
        else
        begin

         if boss_explosion>=8 then          begin
         explosion(xboss,yboss,random(400),random(300),yellow_explosion);     boss_explosion:=0; end;
        r:=random(4)+1;
 case r of
 1:if (xboss<=1366-dx-128)then xboss:=xboss+dx;
 2:if (yboss>=6) then yboss:=yboss-6;
 3:if (xboss>=dx) then xboss:=xboss-dx;
 4:if (yboss<=768-6-70)then yboss:=yboss+6;
 end;
      if xBoss>=1366-494 then xboss:=1366-494;
      if xBoss<=0 then xboss:=0;
      if yboss+245>=602 then boss_up:=true;


        end;

       putimage(xBoss,yBoss,ship_enemy_boss^,xorput);
       end;

for k:=1 to 2 do
with bot_healers[k] do
if priznak_bot then
        begin
        if (boss_delay_if_hp30>=30) then boss_delay_if_hp30:=0;
        if (boss_delay_if_hp30>=20) then
        boss2_delay:=0;
        if (boss_delay_if_hp30>=10) then
        boss_delay:=0;
        boss_delay_if_hp30:=boss_delay_if_hp30+1;
        if k=1 then
        begin


        if (healer_bot_m<=20)and(healers_bot_pusk[healer_bot_m])and(healer_bot_delay>=8) then
                begin


                x_heal_particle[healer_bot_m]:=x_bot+160;
                y_heal_particle[healer_bot_m]:=y_bot+80;
                dx_heal_particle[healer_bot_m]:=5;
                if (healer_bot_m mod 2 = 0) then putimage(x_heal_particle[healer_bot_m],y_heal_particle[healer_bot_m],particle_heal[1]^,xorput);

                if (healer_bot_m mod 2 <> 0) then putimage(x_heal_particle[healer_bot_m],y_heal_particle[healer_bot_m],particle_heal[2]^,xorput);

                healers_bot_pusk[healer_bot_m]:=false;
                healer_bot_m:=healer_bot_m+1;
               //  healer_bot_delay:=0;

                if healer_bot_m>20 then healer_bot_m:=1;
                end;
        putimage(x_bot,y_bot,bot_healer_r^,xorput);
        if hp_boss<=100 then
        x_bot:=x_bot+dx_bot
        else
        begin
                x_bot:=x_bot-dx_bot;
                if (x_bot>=xboss-100) then
                begin
                priznak_bot:=false;
                putimage(x_bot,y_bot,bot_healer_r^,xorput);
                end;
                end;
        y_bot:=yboss+50;
        if (x_bot<0)or(x_bot<=xboss-300)or(x_bot>=1266)or(x_bot>=xboss+800) then x_bot:=x_bot-dx_bot;
     //   sleep(1);
        putimage(x_bot,y_bot,bot_healer_r^,xorput);
        end
        else
        begin

                begin
        if (healer_bot_2_m<=20)and(healers_bot_2_pusk[healer_bot_2_m])and(healer_bot_delay>=8) then
                begin


                x_heal_2_particle[healer_bot_2_m]:=x_bot-47;
                y_heal_2_particle[healer_bot_2_m]:=y_bot+80;
                dx_heal_2_particle[healer_bot_2_m]:=-5;
                if (healer_bot_2_m mod 2 = 0) then putimage(x_heal_2_particle[healer_bot_2_m],y_heal_2_particle[healer_bot_2_m],particle_heal[1]^,xorput);

                if (healer_bot_2_m mod 2 <> 0) then putimage(x_heal_2_particle[healer_bot_2_m],y_heal_2_particle[healer_bot_2_m],particle_heal[2]^,xorput);

                healers_bot_2_pusk[healer_bot_2_m]:=false;
                healer_bot_2_m:=healer_bot_2_m+1;
                 healer_bot_delay:=0;

                if healer_bot_2_m>20 then healer_bot_2_m:=1;
                end;
                end;
         putimage(x_bot,y_bot,bot_healer^,xorput);
      //  x_bot:=x_bot+dx_bot;
        if hp_boss<=100 then
        x_bot:=x_bot+dx_bot
        else
        begin
                x_bot:=x_bot-dx_bot;
                if (x_bot<=xboss+400) then
                begin
                priznak_bot:=false;
                putimage(x_bot,y_bot,bot_healer^,xorput);
                end;
                end;
        y_bot:=yboss+50;

        if (x_bot<0)or(x_bot<=xboss-300)or(x_bot>=1174)or(x_bot>=xboss+800) then x_bot:=x_bot-dx_bot;
        if x_bot>1174 then x_bot:=1174;
      //  sleep(1);
        putimage(x_bot,y_bot,bot_healer^,xorput);
        end;
        end;


mouseinit(act);


for i:=1 to 20 do
if healers_bot_pusk[i]=false then
begin
if i mod 2 = 0 then
        begin

        putimage(x_heal_particle[i],y_heal_particle[i],particle_heal[1]^,xorput);
        x_heal_particle[i]:=x_heal_particle[i]+dx_heal_particle[i];
        if x_heal_particle[i]>=xboss+30 then
                begin healers_bot_pusk[i]:=true;
                putimage(x_heal_particle[i],y_heal_particle[i],particle_heal[1]^,xorput);
                hp_boss:=hp_boss+1;
                end;
       // sleep(1);
        putimage(x_heal_particle[i],y_heal_particle[i],particle_heal[1]^,xorput);
        end;
if i mod 2 <> 0 then
        begin

        putimage(x_heal_particle[i],y_heal_particle[i],particle_heal[2]^,xorput);
        x_heal_particle[i]:=x_heal_particle[i]+dx_heal_particle[i];
        if x_heal_particle[i]>=xboss+30 then
                begin healers_bot_pusk[i]:=true;
                putimage(x_heal_particle[i],y_heal_particle[i],particle_heal[2]^,xorput);
                hp_boss:=hp_boss+random(2);
                end;
       // sleep(1);
        putimage(x_heal_particle[i],y_heal_particle[i],particle_heal[2]^,xorput);
        end;
end;
for i:=1 to 20 do
if healers_bot_2_pusk[i]=false then
begin
if i mod 2 = 0 then
        begin

        putimage(x_heal_2_particle[i],y_heal_2_particle[i],particle_heal[1]^,xorput);
        x_heal_2_particle[i]:=x_heal_2_particle[i]+dx_heal_2_particle[i];
        if x_heal_2_particle[i]<=xboss+444 then
                begin healers_bot_2_pusk[i]:=true;
                putimage(x_heal_2_particle[i],y_heal_2_particle[i],particle_heal[1]^,xorput);
                hp_boss:=hp_boss+1;
                end;
       // sleep(1);
        putimage(x_heal_2_particle[i],y_heal_2_particle[i],particle_heal[1]^,xorput);
        end;
if i mod 2 <> 0 then
        begin

        putimage(x_heal_2_particle[i],y_heal_2_particle[i],particle_heal[2]^,xorput);
        x_heal_2_particle[i]:=x_heal_2_particle[i]+dx_heal_2_particle[i];
        if x_heal_2_particle[i]<=xboss+444 then
                begin healers_bot_2_pusk[i]:=true;
                putimage(x_heal_2_particle[i],y_heal_2_particle[i],particle_heal[2]^,xorput);
                hp_boss:=hp_boss+random(2);
                end;
       // sleep(1);
        putimage(x_heal_2_particle[i],y_heal_2_particle[i],particle_heal[2]^,xorput);
        end;
end;

for i:=1 to 200 do
if boss_pusk[i]=false then
begin
if (i mod 2 <> 0) then
        begin
        polet_boss_plazma(x_r_boss[i],y_r_boss[i],dy_r_boss[i],dx_r_boss[i],ugl_boss[i],boss_pusk[i],boss_plazma);
        if proverka(x_r_boss[i],y_r_boss[i],24,24,xCh+40,yCh+64,1,1) then
                         begin
                           putimage(x_r_boss[i],y_r_boss[i],boss_plazma^,xorput);
                           boss_pusk[i]:=true;
                           explosion(x_r_boss[i],y_r_boss[i],32,32,yellow_explosion);
                        // a:=a-1;
                        a:=a+1;
                        score:=score-70;
                        if a>4 then flag:=false;
                         end;

        end
else
        begin
        polet_boss_pulya(x_r_boss[i],y_r_boss[i],dy_r_boss[i],dx_r_boss[i],boss_pusk[i],pulya_purple_small);
                if proverka(x_r_boss[i],y_r_boss[i],24,24,xCh+40,yCh+64,1,1) then
                         begin
                           putimage(x_r_boss[i],y_r_boss[i],pulya_purple_small^,xorput);
                           boss_pusk[i]:=true;
                           explosion(x_r_boss[i],y_r_boss[i],32,32,yellow_explosion);
                        // a:=a-1;
                        a:=a+1;
                        score:=score-70;
                        if a>4 then flag:=false;
                         end;
                         end;
end;


for i:=1 to 200 do
if boss2_pusk[i]=false then
begin
if (i mod 2 <> 0) then
        begin
        polet_boss_plazma(x_r_boss2[i],y_r_boss2[i],dy_r_boss2[i],dx_r_boss2[i],ugl_boss2[i],boss2_pusk[i],boss_plazma);
        if proverka(x_r_boss2[i],y_r_boss2[i],24,24,xCh+40,yCh+64,1,1) then
                         begin
                           putimage(x_r_boss2[i],y_r_boss2[i],boss_plazma^,xorput);
                           boss2_pusk[i]:=true;
                           explosion(x_r_boss2[i],y_r_boss2[i],32,32,yellow_explosion);
                        // a:=a-1;
                        a:=a+1;
                        score:=score-70;
                        if a>4 then flag:=false;
                         end;

        end
else
         begin
         polet_boss_pulya(x_r_boss2[i],y_r_boss2[i],dy_r_boss2[i],dx_r_boss2[i],boss2_pusk[i],pulya_purple_small);
                if proverka(x_r_boss2[i],y_r_boss2[i],24,24,xCh+40,yCh+64,1,1) then
                         begin
                           putimage(x_r_boss2[i],y_r_boss2[i],pulya_purple_small^,xorput);
                           boss2_pusk[i]:=true;
                           explosion(x_r_boss2[i],y_r_boss2[i],32,32,yellow_explosion);
                        // a:=a-1;
                        a:=a+1;
                        score:=score-70;
                        if a>4 then flag:=false;
                         end;
         end;
end;
for i:=1 to 100 do
if pusk[i] then
polet(x_r[i],y_r[i],dy_r[i],pusk[i],pulya);
for i:=1 to 100 do
        if pusk[i] then
        begin
        if proverka(xboss+220,yboss,240,302,x_r[i],y_r[i],32,32) then
                begin
                putimage(x_r[i],y_r[i],pulya^,xorput);
                pusk[i]:=false;
                explosion(x_r[i],y_r[i],32,32,yellow_explosion);
                hp_boss:=hp_boss-1;
                if hp_boss<=0 then begin
                priznak_boss:=false;
                putimage(xboss,yboss,ship_enemy_boss^,xorput);
                xboss:=-300;
                yboss:=-340;
                kolvo:=kolvo+1;
                score:=score+8460;
                next_lvl:=true;
                end;
                end;
        for k:=1 to 2 do
        with bot_healers[k] do
        if priznak_bot then
                begin
                if proverka(x_bot,y_bot,192,192,x_r[i],y_r[i],1,1) then
                         begin
                           putimage(x_r[i],y_r[i],pulya^,xorput);
                           pusk[i]:=false;
                           explosion(x_r[i],y_r[i],32,32,yellow_explosion);
                         hp_bot:=hp_bot-1;
                         end;
                if hp_bot<=0 then
                        begin
                        if k=1 then
                        putimage(x_bot,y_bot,bot_healer_r^,xorput)
                        else
                        putimage(x_bot,y_bot,bot_healer^,xorput);
                        priznak_bot:=false;
                        score:=score+250;
                        end;
                end;
        end;
//delay(20);

until (flag=false)or(ch=#27)or(CloseGraphRequest)or(next_lvl=true);
if flag=false then begin score:=score-1500;  restart; flag:=true; ch:=#0;  lvl_3; end;
if next_lvl=true then
 begin
// record_records(records);

 win;
 end;
end;


procedure init_2;
var n:integer;
begin
ris('meteor.bmp',meteor[0]);
ris('meteor_2.bmp',meteor[1]);
ris('meteor_3.bmp',meteor[2]);
dy_r[k]:=24;
pusk[k]:=false;
m:=1;
for k:=1 to 32 do
begin
        with meteor_kos[k]do
        begin
        x_meteor:=random(1366+128)+256;
        y_meteor:=random(30)-200;
        repeat

        dx_meteor:=random(14)-18;
          n:=random(3);
         putimage(x_meteor,y_meteor,meteor[n]^,xorput);
        dy_meteor:=random(14)+4;

        until (dy_meteor)and(dx_meteor)<>0;

        priznak_meteor:=true;
        hp_meteor:=4;
        end;
        end;

putimage(xCh,yCh,ship^,xorput);
end;

procedure lvl_2;
var i:integer;
begin
myDelay:=0;
cleardevice;
init_2;
cleardevice;
putimage(xCh,yCh,ship^,xorput);
a:=0;
next_lvl:=false;
repeat
writeln(a);
timer;
HUD(a,s,score,kolvo,HP,HUD_initialization,flag);
MyDelay:=MyDelay+1;
for k:=1 to 32 do
begin
with meteor_kos[k]do
        if priznak_meteor then
        neupr_kos(x_meteor,y_meteor,dy_meteor,dx_meteor,meteor[n]);
end;

//delay(15);
for i:=1 to 100 do
if pusk[i] then
polet(x_r[i],y_r[i],dy_r[i],pusk[i],pulya);

for K:=1 to 32 do
with meteor_kos[k] do
        if priznak_meteor then
        for i:=1 to 100 do
        if pusk[i] then
        if proverka(x_meteor+32,y_meteor+32,64,64,x_r[i],y_r[i],1,1) then
                begin

                putimage(x_r[i],y_r[i],pulya^,xorput);
                pusk[i]:=false;
                explosion(x_r[i],y_r[i],32,32,yellow_explosion);
                hp_meteor:=hp_meteor-1;
                if hp_meteor=0 then begin priznak_meteor:=false; putimage(x_meteor,y_meteor,meteor[n]^,xorput); kolvo:=kolvo+1; score:=score+65;   end;

                end;


for K:=1 to 32 do
       // begin

        with meteor_kos[k] do
        begin
        if priznak_meteor=false then
        begin
        priznak_meteor:=true;
        x_meteor:=random(1366+128)+256;
        y_meteor:=random(30)-200;
        end;
        if priznak_meteor then
        if proverka(x_meteor,y_meteor,64,64,xch,ych,64,64) then
                begin
                putimage(x_meteor,y_meteor,meteor[n]^,xorput);
                priznak_meteor:=false;
                a:=a+1;
                score:=score-70;
                if a>4 then flag:=false;
              //  if a>=4 then a:=4;

                        end;
                if kolvo>=192 then
                begin
             //   cleardevice;
                kolvo:=0;
                s:=s+1;
                if s=4 then next_lvl:=true;
             //   init_2;
                        end;

                end;

putimage(xCh,yCh,ship^,xorput);
xCh:=smallint(getmousex);
yCh:=smallint(getmousey);
if yCh<=380 then yCh:=380;
if xCh>=1366-128 then xCh:=1366-128;
putimage(xCh,yCh,ship^,xorput);
mouseinit(act);
for i:=1 to 100 do
if pusk[i] then
polet(x_r[i],y_r[i],dy_r[i],pusk[i],pulya);
//delay(10);
if (keypressed)then
       begin
        ch:=readkey;
        if ch=#0 then ch:=readkey;
        end;
until (flag=false)or(ch=#27)or(CloseGraphRequest)or(next_lvl=true);
if ch=#27 then begin ch:=#0; menu; end;
if next_lvl=true then
        begin
        S:=0;
        dialog_pos:=dialog_pos+1;
        dialog;
        cleardevice;
        lvl_3;
        end;
if flag=false then
        begin
        restart;
        flag:=true;
        s:=0;
        kolvo:=0;
        lvl_2;
        end;
end;

procedure restart;
var
i:integer;
panda,gameover:pointer;
begin
cleardevice;
HUD_initialization:=true;
hp:=2;
ris('panda.bmp',panda);
ris('gameover.bmp',gameover);
changefont(35);
Mydelay:=0;
for i:=1 to 100 do
pusk[i]:=false;
enemy_attack_delay:=0;
putimage(900,350,panda^,xorput);
putimage(0,100,gameover^,xorput);
Outtextxy(0,600,'Looks like you died, do you want to start over?');
changefont(30);
Outtextxy(0,700,'Push Enter to Yes, Esc to No.');
repeat
if (keypressed)then
       begin
        ch:=readkey;
        if ch=#0 then ch:=readkey;
        if ch=#27 then menu;
        end;
until ch=#13;
ch:=#0;
end;

procedure logo;
var logo:pointer;
begin
ris('logo.bmp',logo);
putimage(0,0,logo^,xorput);

        repeat
        if (keypressed)then
       begin
        ch:=readkey;
        if ch=#0 then ch:=readkey;
        end;
        delay(10);
        until (ch=#27)or(ch=#13);
        ch:=#0;
        menu;
end;

procedure dialog;
var
captian_logo:pointer;
a,i:smallint;

begin
cleardevice;
HUD_initialization:=true;
a:=35;
ris('Captain_earth.bmp',captian_logo);
changefont(a);
for i:=1 to 100 do
pusk[i]:=false;
if dialog_pos=0 then
        begin
        Putimage(0,0,captian_logo^,xorput);
        outtextxy(250,0,'Attention ! In your sector found Dominators. You need to leave it urgently.');
        outtextxy(250,100,'Your name? ');
        putimage(0,200,hero_logo[picked_hero]^,xorput);
        outtextxy(250,250,'');
        ReadBuf(t,0);
        Putimage(0,500,captian_logo^,xorput);
        outtextxy(250,500,'');
        WriteBuf('Ok ,'+t+', goodluck! ');
        readkey;

        lvl_1;
        end;
if dialog_pos=1 then
        begin
        Putimage(0,0,captian_logo^,xorput);
        outtextxy(250,0,'A huge cluster of meteorites is approaching you.');
        outtextxy(250,100,'Be careful.');
        readkey;
        HP:=hP+1;
        lvl_2;
        end;
if dialog_pos=2 then
        begin
        Putimage(0,0,captian_logo^,xorput);
        outtextxy(250,0,'It seems this is their main supercomputer');
        outtextxy(250,50,' quickly finish it off.');
        outtextxy(250,100,'Be careful.');
        readkey;
        HP:=hP+1;
        lvl_3;
        end;
end;

procedure lvl_1;
var
x_nlo_1,y_nlo_1:integer;
i,kolvo:integer;
begin
cleardevice;
for i:=1 to 50 do
nlo1_shots_pusk[i]:=true;
for i:=1 to 50 do
nlo2_shots_pusk[i]:=true;
init;
putimage(xCh,yCh,ship^,xorput);
//m:=1;
if s=0 then
 begin
a:=0;
kolvo:=0;
next_lvl:=false;
end;
with enemy_rand[1]do
putimage(x_enemy,y_enemy,ship_enemy^,xorput);
score:=score+1;
repeat
timer;
HUD(a,s,score,kolvo,HP,HUD_initialization,flag);
enemy_attack_delay:=enemy_attack_delay+1;
MyDelay:=MyDelay+1;
putimage(xCh,yCh,ship^,xorput);
xCh:=smallint(getmousex);
if xCh>=1366-128 then xCh:=1366-128;
putimage(xCh,yCh,ship^,xorput);
for k:=1 to 32 do
begin
with enemy_rand[k]do
        if (priznak) then
       { begin
        x_nlo_1:=x_enemy;
        y_nlo_1:=y_enemy;
        for i:=k+1 to 32 do
        with enemy_rand[i] do
        if not  proverka(x_nlo_1,y_nlo_1,128,128,x_enemy,y_enemy,1,1) then
        with enemy_rand[k] do}
        neupr_down(x_enemy,y_enemy,dy_enemy,ship_enemy);

{with enemy_rand[k]do
        if priznak then
        neupr_goriz(x_enemy,y_enemy,dx_enemy,ship_enemy); }
end;
for k:=1 to 2 do
begin
with nlo_shots_logarifmich[k]do
        if priznak_nlo_shots then
           neupr_Logarifmich(x_nlo_shots,y_nlo_shots,dx_nlo_shots,nlo_shots_p);
with nlo_shots_logarifmich[k]do
       if priznak_nlo_shots then
       for i:=1 to 100 do
       if pusk[i] then
       if proverka(x_nlo_shots,y_nlo_shots,128,128,x_r[i],y_r[i],32,32) then
       begin
        putimage(x_r[i],y_r[i],pulya^,xorput);
        pusk[i]:=false;
         explosion(x_r[i],y_r[i],32,32,yellow_explosion);
        hp_nlo_shots:=hp_nlo_shots-1;
        if hp_nlo_shots=0 then begin priznak_nlo_shots:=false; putimage(x_nlo_shots,y_nlo_shots,nlo_shots_p^,xorput); score:=score+90;   kolvo:=kolvo+15;  end;
       end;
       with nlo_shots_logarifmich[1]do
        if (priznak_nlo_shots)and(m_nlo1_shots<=50)and(enemy_attack_delay>=14) then
                         begin
                         x_nlo1_shots_pulya[m_nlo1_shots]:=x_nlo_shots+64;
                         y_nlo1_shots_pulya[m_nlo1_shots]:=y_nlo_shots+108;
                         dy_nlo1_shots_pulya[m_nlo1_shots]:=15;
                         putimage(x_nlo1_shots_pulya[m_nlo1_shots],y_nlo1_shots_pulya[m_nlo1_shots],pulya_red^,xorput);
                         nlo1_shots_pusk[m_nlo1_shots]:=false;
                         M_nlo1_shots:=m_nlo1_shots+1;
                        // enemy_attack_delay:=0;
                         if m_nlo1_shots=50 then m_nlo1_shots:=1;
                         end;
        with nlo_shots_logarifmich[2]do
        if (priznak_nlo_shots)and(m_nlo2_shots<=50)and(enemy_attack_delay>=14) then
                         begin
                         x_nlo2_shots_pulya[m_nlo2_shots]:=x_nlo_shots+64;
                         y_nlo2_shots_pulya[m_nlo2_shots]:=y_nlo_shots+108;
                         dy_nlo2_shots_pulya[m_nlo2_shots]:=20;
                         putimage(x_nlo2_shots_pulya[m_nlo2_shots],y_nlo2_shots_pulya[m_nlo2_shots],pulya_red^,xorput);
                         nlo2_shots_pusk[m_nlo2_shots]:=false;
                         M_nlo2_shots:=m_nlo2_shots+1;
                         enemy_attack_delay:=0;
                         if m_nlo2_shots=50 then m_nlo2_shots:=1;
                         end;
end;
MouseInit(act);
for i:=1 to 50 do
if nlo1_shots_pusk[i]=false then
begin
polet_down(x_nlo1_shots_pulya[i],y_nlo1_shots_pulya[i],dy_nlo1_shots_pulya[i],nlo1_shots_pusk[i],pulya_red);
if proverka(x_nlo1_shots_pulya[i],y_nlo1_shots_pulya[i],98,50,xCh+60,yCh+64,1,1) then
        begin
        putimage(x_nlo1_shots_pulya[i],y_nlo1_shots_pulya[i],pulya_red^,xorput);
        explosion(x_nlo1_shots_pulya[i],y_nlo1_shots_pulya[i],32,1,yellow_explosion);
        a:=a+1;
        nlo1_shots_pusk[i]:=true;
        score:=score-150;
        If a>=5 then flag:=false;
        end;
end;
for i:=1 to 50 do
if nlo2_shots_pusk[i]=false then
begin
polet_down(x_nlo2_shots_pulya[i],y_nlo2_shots_pulya[i],dy_nlo2_shots_pulya[i],nlo2_shots_pusk[i],pulya_red);
if proverka(x_nlo2_shots_pulya[i],y_nlo2_shots_pulya[i],98,50,xCh+60,yCh+64,1,1) then
        begin
        putimage(x_nlo2_shots_pulya[i],y_nlo2_shots_pulya[i],pulya_red^,xorput);
        explosion(x_nlo1_shots_pulya[i],y_nlo1_shots_pulya[i],32,1,yellow_explosion);
        a:=a+1;
        nlo2_shots_pusk[i]:=true;
        score:=score-150;
        If a>=5 then flag:=false;
        end;
end;
for i:=1 to 100 do
if pusk[i] then
polet(x_r[i],y_r[i],dy_r[i],pusk[i],pulya);
for K:=1 to 20 do
        begin
        with enemy_rand[k] do
        if (priznak=false)and(s<=2) then

        begin
        x_enemy:=random(1366-128);
        y_enemy:=random(20)-300;
        repeat

       // dx_enemy:=-8+random(14);
         putimage(x_enemy,y_enemy,ship_enemy^,xorput);
        dy_enemy:=random(20)+5;

        until dy_enemy<>0;

        priznak:=true;
        hp_enemy:=1+random(2);
        end;
        with enemy_rand[k]do
        if priznak then
        if proverka(x_enemy,y_enemy,128,128,xCh,yCh,64,64) then
                begin
                putimage(x_enemy,y_enemy,ship_enemy^,xorput);
                a:=a+1;
                priznak:=false;
                kolvo:=kolvo+1;
                score:=score-250;
                If a>=5 then flag:=false;
                end;
        with enemy_rand[k] do
        if priznak then
        for i:=1 to 100 do
        if pusk[i] then
        if proverka(x_enemy,y_enemy,128,128,x_r[i],y_r[i],32,32) then
                begin

                putimage(x_r[i],y_r[i],pulya^,xorput);
                pusk[i]:=false;
                explosion(x_r[i],y_r[i],32,32,yellow_explosion);
                hp_enemy:=hp_enemy-1;
                if hp_enemy=0 then begin priznak:=false; putimage(x_enemy,y_enemy,ship_enemy^,xorput); score:=score+30;   kolvo:=kolvo+1;  end;
                if kolvo>=30 then
                begin
               // cleardevice;
                kolvo:=0;
                s:=s+1;

                if s=3 then next_lvl:=true;

              //  cleardevice;
               // init;
              //  lvl_1;

        end;
end;
                end;



//delay(20);
if (keypressed)then
       begin
        ch:=readkey;
        if ch=#0 then ch:=readkey;
        end;

until (flag=false)or(ch=#27)or(CloseGraphRequest)or(next_lvl=true);
if ch=#27 then begin ch:=#0; menu; end;
if next_lvl=true then
        begin
        s:=0;
        dialog_pos:=1;
        dialog;
        end;
if flag=false then
        begin
        restart;
        for i:=1 to 50 do
        nlo1_shots_pusk[i]:=true;
        for i:=1 to 50 do
        nlo2_shots_pusk[i]:=true;
        flag:=true;
        s:=0;
        kolvo:=0;
        lvl_1;
        end;
end;


procedure help;
begin
cleardevice;
changefont(35);

outtextxy(100,100,'Mouse to move');
outtextxy(100,150,'L_button to shoot');

outtextxy(1100,getmaxy-50,'Press Esc to quit');
repeat
if keypressed then
begin
ch:=readkey;
if ch=#0 then ch:=readkey;
end;
until (ch=#27)or(CloseGraphRequest);
ch:=#0;
menu;
end;


 procedure inventory;
 var inv:pointer;
begin
cleardevice;
ris('Inventory.bmp',inv);
putimage(0,0,inv^,xorput);


//ttextxy(200,200,'Inventory');
readkey;
lvl_1;
end;

procedure menu;
var

ch:char;
strelka,start,dudec,dudec2,earth,zvezda:pointer;
x,y,x_gif,y_gif,x_zvezda,y_zvezda,x_zvezda_new,y_zvezda_new,i:integer;
Gif_delay:smallint;
begin
for i:=1 to 100 do
pusk[i]:=false;
for i:=1 to 50 do
nlo1_shots_pusk[i]:=true;
for i:=1 to 50 do
nlo2_shots_pusk[i]:=true;
enemy_attack_delay:=0;
Mydelay:=0;
setcolor(Flax);
cleardevice;
ris('zvezda.bmp',zvezda);
ris('earth.bmp',earth);
ris('strelka.bmp',strelka);
ris('MENU_START.bmp',start);
x:=200;
y:=200;
x_gif:=600;
y_gif:=300;

Changefont(50);
outtextxy(x-100,y-150,'Space odesy: the depth of time');
changefont(30);
Outtextxy(200,220,'StArT');
//putimage(180,190,start^,xorput);

outtextxy(x,y+70,'Help');
outtextxy(x,y+120,'Exit');
x:=50;
y:=210;
putimage(x,y,strelka^,xorput);
putimage(600,300,earth^,xorput);
putimage(660,200,zvezda^,xorput);
if song1 then
 begin
sndPlaySound('C:\fpc\3.0.4\bin\i386-win32\what_is_love.wav', snd_Async or snd_NoDefault);
 song1:=false; end;

repeat
timer;
gif_delay:=gif_delay+1;
if keypressed then
begin
ch:=readkey;
if ch=#0 then ch:=readkey;
putimage(x,y,strelka^,xorput);
case ch of
#72 : if y=210 then y:=310 else y:=y-50;
#80 : if y=310 then y:=210 else y:=y+50;
end;
putimage(x,y,strelka^,xorput);
end;
putimage(x_gif,y_gif,earth^,xorput);
 i:=i+2;
        x_gif:=round(330*sin(i*Pi/180))+780;
        y_gif:=round(330*cos(i*Pi/180))+280;
        putimage(x_gif,y_gif,earth^,xorput);
        sleep(20);

//putimage(500,300,dudec^,xorput);

until ch=#13;
case y of
210 : hero_chose(act);
260 : help;
310 : halt;
end;
end;


begin


SetWindowSize(1366,768);
gd:=nopalette;
gm:=mCustom;
initGraph(gd,gm,'Space Odesy');
song1:=true;
song2:=true;
HUD_initialization:=true;
HP:=3;
//record_records(records);
init;

menu;
//lvl_1;
logo;

{lvl_3;
//menu;}


//readkey;
closeGraph;

end.
