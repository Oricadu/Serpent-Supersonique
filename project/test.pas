uses wingraph, wincrt;
const
	f = 'Times';
var gd, gm, x, y, i: integer;

procedure ShadingEffect;
var i:byte; 
begin
  for i := 50 to 250 do
 	begin 
    Delay(100); //set temporization here
    SetRGBPalette(White,i,i,i);
 	end;
end;

begin
	randomize;
	gd := detect;
	initgraph (gd, gm, '');
	//ShadingEffect;
	SetColor(White);
	//SetRGBPalette(White,1,1,1);
	//SetTextJustify(CenterText, TopText);
	{
	for i := 0 to 8 do
	begin
		outtextxy(200, i * 30, 'Hello, World!');
	end;
}
	//SetFontName('Times'); 
	settextstyle(f, 0, 30);
	outtextxy(200, 200, 'Hello, World!');



  readkey;
  closegraph;
end.












