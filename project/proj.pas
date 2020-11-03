uses WinCrt, WinGraph, SysUtils, WinMouse;

const

hgtCar = 128;    // Длина и ширина bmp
wdhCar = 64;     // изображения машины

K = 10;     // Размер массива полицейских автомобилей

// Коды клавиш
//
up = #72;     WW = #119;  esc = #27;
down = #80;   SS = #115;  enter = #13;
right = #77;  DD = #100;  space = #32;
left = #75;   AA = #97;

ZZ = #122; II = #105; NN = #110; OO = #111;

var

key : char; // Нажатая клавиша
gd, gm, hgtScreen : integer; // Технические значения

xCar, yCar, xCarStd, yCarStd, spdxCar, spdyCar : integer; // Все характеристики машины
upgradeLvl : array[1..2, 1..3] of byte;
coins, highscore,
lvl, score, earnedCoins : integer;           // Статистики - уровень сложности, кол-во очков и т.д.
strScore, strCoins, strHighscore : string[6]; // Статистики, переведенные в строку

// Всё, что связано со счетчиками
//
i, j : integer;
a, policeToSpawn, cPolice, newPolice, cSuv, newSuv, // Для спавна полиции
cTitle, // Для заставки
cCarMenu, newCarMenu, // Для спавна в меню проезжающей мимо машины
cDamageResist, cBlinks : integer;

yBg, spdBg : integer;

// Массивы переменных, каждая из которых принадлежит определенной полицейской машине (N элемента в массиве = N машины)
//
xPolice, yPolice, spdxPolice, spdyPolice, xDirt : array[1..K] of integer;
policeMoving : array[1..K] of boolean;
animPolice, animPoliceBroken : array[1..K] of animattype;
hgtPolice, wdhPolice : array[1..K] of byte;
xWarn : integer;        // 	    Предупреждение o полицейском джипе

// Все картинки
//
animCoin, animSelect, animSelected : animattype;  	// Все картинки, связанные с магазином улучшений
animSlot : array[1..2, 1..3] of animattype;
animSlot3 : array[0..2] of animattype;
pointerBg, pointerRoad : pointer;	// Картинки
animRoad, animVoid,                 // для фона
animWarn : animattype;
animPoliceL, animPoliceR : array[1..5] of animattype;     // Картинки для машин полиции
animDirt, animPoliceLBroken, animPoliceRBroken,animPoliceSuv, animPoliceSuvBroken,
animCar, animCarBroken : animattype;   // Картинки для машины, которую нужно оборонять
animF1, animF1Broken : animattype;
animStdCar, animStdCarBroken : animattype;
animBigfoot, animBigfootBroken : animattype;

ext, cntinue, carMenu, mouseHold, warning, isDamageResist, carIsVisible : boolean; // Boolean переменные

procedure LoadSavedGame;
var saveFile : text;
begin
    Assign(saveFile, 'Save.pas');
    if (FileExists('Save.pas')) then
    begin
        Reset(saveFile);                      // Открываем файл для чтения, перекидываем в переменные по одной строке из файла
        ReadLn(saveFile, coins);              // Строка 1 в файле - кол-во заработанных монет
        ReadLn(saveFile, highscore);          // Строка 2 - рекорд по кол-ву очков в одной игре
        for i := 1 to 2 do                    // Строки 3-8 - состояния покупок в магазине
    		for j := 1 to 3 do
        	begin
                ReadLn(saveFile, upgradeLvl[i, j]);
        	end;
        Close(saveFile);
    end
    else
    begin
    	coins := 0;
        highscore := 0;
        for i := 1 to 2 do
    		for j := 1 to 3 do
        	begin
                upgradeLvl[i, j] := 0;
        	end;
    end;
end;

procedure SaveGame;
var saveFile : text;
begin
    Assign(saveFile, 'Save.pas');
    ReWrite(saveFile);                      // То же, что и в пред. процедуре, только теперь мы записываем переменные в файл
    WriteLn(saveFile, coins);
    WriteLn(saveFile, highscore);
    for i := 1 to 2 do
    	for j := 1 to 3 do
        begin
        	WriteLn(saveFile, upgradeLvl[i, j]);
        end;
    Close(saveFile);
end;

function Load(fileName : string) : pointer;
var f : file; size : longint; p : pointer;
begin
	Assign(f, fileName);
    Reset(f, 1);
    if (FileExists(fileName)) then
    begin
        size := filesize(f);
        GetMem(p, size);
        BlockRead(f, p^, size);
        Close(f);
        Load := p;
    end;
end;

procedure NewAnim (a, b : integer; fileName : string; var anim : animattype; col : longint);
var p : pointer;
begin
    p := Load(fileName);
    ClearDevice;
    SetFillStyle(1, col);
    Bar(0, 0, GetMaxX, GetMaxY);
    PutImage(0, 0, p^, 0);
    GetAnim(0, 0, a, b, col, anim);
    FreeMem(p);
    ClearDevice;
end;

procedure InitData;
begin
    xCarStd := (GetMaxX div 2) + 22;
    yCarStd := 3*(GetMaxY div 4);
    xCar := xCarStd;
    yCar := GetMaxY;
    spdxCar := 6 + upgradeLvl[1, 2];
    spdyCar := 9 + upgradeLvl[1, 2];
    yBg := 0;
    spdBg := 8;
    hgtScreen := GetMaxY;
    score := 0;
    cPolice := 0;
    carIsVisible := true;
    cCarMenu := 0;
    newPolice := 0;
    newCarMenu:= 0;
    key := ' ';
    for i:=1 to K do
    begin
        policeMoving[i] := false;
        xDirt[i] := -200;
    end;
end;

procedure Loading;
var s, s1 : string[2];
part, totalAmountOfParts : byte;
animDots : animattype;
xDots, yDots : integer;
begin
    totalAmountOfParts := 14;
    xDots := GetMaxX div 2 - 303;
    yDots := GetMaxY div 3;
    pointerBg := Load('bg.bmp');
    NewAnim(606, 146, 'DOTS.bmp', animDots, White);
    for part:=0 to totalAmountOfParts do
    begin
        case part of

            0:
                Delay(1);

        	1:
            begin
                InitData;
    			LoadSavedGame;
            end;

            2:
            begin
    			NewAnim(680, GetMaxY, 'road.bmp', animRoad, White);
                pointerRoad := Load('road.bmp');
                NewAnim(GetMaxX, GetMaxY, 'void.bmp', animVoid, White);
            end;

            3:
            begin
            	NewAnim(wdhCar, hgtCar, 'car.bmp', animStdCar, White);
    			NewAnim(wdhCar, hgtCar, 'car_broken.bmp', animStdCarBroken, White);
            end;

            4:
            begin
            	NewAnim(wdhCar, hgtCar, 'f1.bmp', animF1, White);
    			NewAnim(wdhCar, hgtCar, 'f1_broken.bmp', animF1Broken, White);
            end;

            5:
            begin
            	NewAnim(wdhCar, hgtCar, 'bigfoot.bmp', animBigfoot, White);
    			NewAnim(wdhCar, hgtCar, 'bigfoot_broken.bmp', animBigfootBroken, White);
            end;

            6:
            begin
            	animCar := animStdCar;
    			animCarBroken := animStdCarBroken;
            end;

            7:
            begin

                NewAnim(wdhCar, hgtCar, 'police_suv.bmp', animPoliceSuv, White);
    			NewAnim(wdhCar, hgtCar, 'police_suv_broken.bmp', animPoliceSuvBroken, white);
            end;

            8:
            begin
            	NewAnim(68, 56, 'dirt.bmp', animDirt, White);
                NewAnim(64, 64, 'warn.bmp', animWarn, White);
            end;

            9:
            begin
                for a := 1 to 5 do
                begin
                	NewAnim(hgtCar, wdhCar, 'police_r.bmp', animPoliceL[a], White);
                	NewAnim(hgtCar, wdhCar, 'police_l.bmp', animPoliceR[a], White);
                end;

            end;

            10:
            begin
                NewAnim(hgtCar, wdhCar, 'police_r_broken.bmp', animPoliceLBroken, White);
    			NewAnim(hgtCar, wdhCar, 'police_l_broken.bmp', animPoliceRBroken, White);
            end;

            11:
            begin
            	NewAnim(64, 64, 'coin.bmp', animCoin, White);
                NewAnim(140, 140, 'shop\select.bmp', animSelect, White);
                NewAnim(136, 136, 'shop\selected.bmp', animSelected, White);
            end;

            12:
            begin
            	NewAnim(128, 128, 'shop\click.bmp', animSlot[1, 1], White);
    			NewAnim(128, 128, 'shop\speed.bmp', animSlot[1, 2], White);
                NewAnim(128, 128, 'shop\sold.bmp', animSlot3[2], White);
            end;

            13:
            begin
                NewAnim(128, 128, 'shop\clickonsuv.bmp', animSlot3[1], White);
                NewAnim(128, 128, 'shop\ymove.bmp', animSlot3[0], White);
            end;

            14:
            begin
            	NewAnim(128, 128, 'shop\car.bmp', animSlot[2, 1], White);
    			NewAnim(128, 128, 'shop\f1.bmp', animSlot[2, 2], White);
    			NewAnim(140, 140, 'shop\bigfoot.bmp', animSlot[2, 3], White);
            end;
        end;
        PutImage(0, 0, pointerBg^, 0);
        PutAnim(xDots, yDots, animDots, TransPut);
        SetFillStyle(1, Black);
        Bar(xDots, yDots + 300, xDots + 606, yDots + 350);
        SetFillStyle(1, DarkGray);
        Bar(xDots + 3, yDots + 303, xDots + 603, yDots + 347);
        SetFillStyle(1, Yellow);
        Bar(xDots + 3, yDots + 303, xDots + 3 + (600 div totalAmountOfParts * part), yDots + 347);
        UpdateGraph(UpdateNow);
    end;
    Bar(xDots + 3, yDots + 303, xDots + 603, yDots + 347);
    repeat
    	UpdateGraph(UpdateNow);
    	Delay(10);
	until (GetMouseButtons = 1) or (KeyPressed);
end;

procedure SelfMove(var x, y : integer; spdx, spdy : integer; anim : animattype);
begin
    PutAnim(x, y, anim, BkgPut);
    x := x + spdx;
    y := y + spdy;
    PutAnim(x, y, anim, TransPut);
end;

procedure RoadMove;
begin
    PutAnim(0, 0, animVoid, TransPut);
    yBg := yBg - spdBg;
    if (yBg < spdBg - 256) then
    begin
        yBg := 0;
    end;
    PutImage(0, yBg, pointerBg^, 0);
    PutImage(GetMaxX div 2 - 340, yBg, pointerRoad^, 0);
    //PutAnim(GetMaxX div 2 - 340, yBg, animRoad, TransPut);
    PutAnim(0, spdBg, animVoid, BkgPut);
end;

procedure PoliceTiming;
var r : integer;
begin
    cSuv := cSuv + 1;
    cPolice := cPolice + 1;

    if (cSuv >= newSuv - 50) then
    begin
    	if not(warning) then
        begin
        	warning := true;
            xWarn := xCar;
            PutAnim(xWarn, 0, animWarn, TransPut);
        end;
        PutAnim(xWarn, 0, animWarn, BkgPut);
        if (cSuv >= newSuv) then
        begin
    		policeToSpawn := policeToSpawn + 1;
            if (policeToSpawn > k) then
            begin
            	policeToSpawn := 1;
            end;

            warning := false;
            policeMoving[policeToSpawn] := true;
            cSuv := 0;
            newSuv := Random(20) + 200;
            wdhPolice[policeToSpawn] := wdhCar;
            hgtPolice[policeToSpawn] := hgtCar;
            xPolice[policeToSpawn] := xWarn;
            yPolice[policeToSpawn] := -hgtCar;
            animPolice[policeToSpawn] := animPoliceSuv;
            animPoliceBroken[policeToSpawn] := animPoliceSuvBroken;
            spdxPolice[policeToSpawn] := 0;
            spdyPolice[policeToSpawn] := 15 + lvl;
            PutAnim(xPolice[policeToSpawn], yPolice[policeToSpawn], animPolice[policeToSpawn], TransPut);
        end;
    end;

    if cPolice >= newPolice then
    begin
    	cPolice := 0;
        newPolice := Random(20) + 50;
		policeToSpawn := policeToSpawn + 1;
        if (policeToSpawn > k) then
        begin
        	policeToSpawn := 1;
        end;
        a := a + 1;
        if (a = 6) then
        begin
        	a := 1;
        end;
        policeMoving[policeToSpawn] := true;
        r := Random(2)+1;

        wdhPolice[policeToSpawn] := hgtCar;
        hgtPolice[policeToSpawn] := wdhCar;
        yPolice[policeToSpawn] := Random(50);
        spdyPolice[policeToSpawn] := 0;
        case r of

        	1:
            begin
            	xPolice[policeToSpawn] := Random(100) - hgtCar;
                spdxPolice[policeToSpawn] := (xCar - xPolice[policeToSpawn] - wdhPolice[policeToSpawn])*spdBg div (yCar - yPolice[policeToSpawn]);
                animPolice[policeToSpawn] := animPoliceL[a];
                animPoliceBroken[policeToSpawn] := animPoliceLBroken;
            end;

            2:
            begin
                xPolice[policeToSpawn] := GetMaxX + Random(100);
            	spdxPolice[policeToSpawn] := (xCar - xPolice[policeToSpawn] + wdhCar)*spdBg div (yCar - yPolice[policeToSpawn]);
            	animPolice[policeToSpawn] := animPoliceR[a];
            	animPoliceBroken[policeToSpawn] := animPoliceRBroken;
            end;

        end;
        xDirt[policeToSpawn] := -200;
        PutAnim(xPolice[policeToSpawn], yPolice[policeToSpawn], animPolice[policeToSpawn], TransPut);
    end;
end;

procedure DirtDraw(xPolice, yPolice, spdxPolice : integer; var xDirt : integer; animDirt : animattype);
begin
    if (abs(xPolice + 64 - GetMaxX div 2) >= 200) then
    begin
        if (abs((xPolice + 64) - (xDirt + 28)) >= 56) then
        begin
        	xDirt := xPolice + 36;
            PutAnim(xPolice, yPolice + 4, animDirt, TransPut);
        end;
    end;
end;

procedure PoliceMove(var xPolice, yPolice, xDirt : integer; spdxPolice, spdyPolice : integer; animPolice : animattype);
begin
	yPolice := yPolice + spdyPolice + spdBg;
    xPolice := xPolice + spdxPolice;
    DirtDraw(xPolice, yPolice, spdxPolice, xDirt, animDirt);
    PutAnim(xPolice, yPolice, animPolice, TransPut);
end;

procedure DamageResist;
begin
    cDamageResist := cDamageResist + 1;
    if (cDamageResist > 10) then
    begin
        if not(carIsVisible) then
        begin
            carIsVisible := true;
        end;
        if (cDamageResist > 20) then
        begin
            cDamageResist := 0;
            cBlinks := cBlinks + 1;
            if (cBlinks > 3) then
            begin
                cBlinks := 0;
                isDamageResist := false;
            end;
        end;
    end
    else
    begin
        if (carIsVisible) then
        begin
            carIsVisible := false;
        end;
    end;
end;

procedure CarMove;
begin
    key := ReadKey;
    case key of

        up, WW :
            if (upgradeLvl[1, 3] > 0) then
            begin
                if yCar > GetMaxY div 4 then
                begin
                    yCar := yCar - spdyCar div 2;
                end;
            end;

        down, SS :
            if (upgradeLvl[1, 3] > 0) then
            begin
                if yCar < 3*(GetMaxY div 4) then
                begin
                    yCar := yCar + spdyCar;
                end;
            end;
        left, AA :
            if xCar > getmaxx div 2 - 270 then
            begin
                xCar := xCar - spdxCar;
            end;

        right, DD :
            if xCar < GetMaxX div 2 + 206 then
            begin
                xCar := xCar + spdxCar;
            end;

    end;
end;

procedure UI(hpCar : integer; strScore : string);
begin
    SetTextStyle(1, 0, 4);
    SetFillStyle(1, Black);
    Bar(0, GetMaxY - TextHeight(strScore), TextWidth(strScore), GetMaxY);
    SetColor(White);
    OutTextXY(0, GetMaxY - TextHeight(strScore), strScore);
    Bar(GetMaxX - 33, GetMaxY - hpCar, GetMaxX, GetMaxY);
    SetFillStyle(1, Yellow);
    Bar(GetMaxX - 25, GetMaxY - hpCar, GetMaxX, GetMaxY);
    SetColor(Black);
end;

procedure MouseClick;
begin
    for i:=1 to K do
    begin
        if (GetMouseX > xPolice[i] - 10 - 50 * upgradeLvl[1, 1]) and (GetMouseX < xPolice[i] + wdhPolice[i] + 10 + 50 * upgradeLvl[1, 1]) then
            if (GetMouseY > yPolice[i] - 10 - 50 * upgradeLvl[1, 1]) and (GetMouseY < yPolice[i] + hgtPolice[i] + 10 + 50 * upgradeLvl[1, 1]) then
            begin
                if (policeMoving[i]) then
                begin
                    score := score + 3;
                    policeMoving[i] := false;
                    PutAnim(xPolice[i], yPolice[i], animPolice[i], BkgPut);
                    PutAnim(xPolice[i], yPolice[i], animPoliceBroken[i], TransPut);
                    break;
                end;
            end;
    end;
    mouseHold := true;
end;

procedure Pause;
var
colResume, colToMenu : longint;
xPaused, yPaused, xResume, yResume, xToMenu, yToMenu : integer;
lineHeight : integer;
earnedCoins : byte;
begin
    key := ' ';

    Str(highscore, strHighscore);
    SetTextStyle(1, 0, 5);
    SetFillStyle(1, Black);
    Bar(0, GetMaxY - TextHeight(strScore), TextWidth(strScore), GetMaxY);
    SetTextStyle(1, 0, 4);
    Bar(TextWidth(strScore) + 15, GetMaxY - TextHeight('ABC'), TextWidth(strScore) + 15 + TextWidth('Highscore:' + strHighscore), GetMaxY);
    SetColor(White);
    SetTextStyle(1, 0, 5);
    OutTextXY(0, GetMaxY - TextHeight(strScore), strScore);
    SetTextStyle(1, 0, 4);
    OutTextXY(TextWidth(strScore) + 15, GetMaxY - TextHeight('ABC'), 'Highscore:' + strHighscore);
    earnedCoins := 2 * lvl;
    Str(score, strScore);
    Str(earnedCoins, strCoins);
    lineHeight := TextHeight('ABC');
    yPaused := (GetMaxY div 2) - (lineHeight div 2 * 5);
    yResume := yPaused + lineHeight * 2;
    yToMenu := yResume + lineHeight * 2;
    xPaused := (GetMaxX div 2) - (TextWidth('PAUSED') div 2);
    xResume := (GetMaxX div 2) - (TextWidth('Resume') div 2);
    xToMenu := (GetMaxX div 2) - (TextWidth('To main menu') div 2);


    SetFillStyle(1, Black);
    Bar(GetMaxX div 2 - 150, yPaused - lineHeight, GetMaxX div 2 + 150, yToMenu + lineHeight * 2);
    SetFillStyle(1, Yellow);
    Bar(GetMaxX div 2 - 150, yPaused - lineHeight + 5, GetMaxX div 2 + 150, yToMenu + (lineHeight * 2) - 5);
    SetColor(Black);
    OutTextXY(xPaused, yPaused, 'PAUSED');

    repeat
            colResume := Black;
            colToMenu := Black;
            if (GetMouseX > xToMenu - 10) and (GetMouseX < GetMaxX - xToMenu + 10) then
            begin
                if (GetMouseY > yResume - 10) and (GetMouseY < yResume + lineHeight + 10) then
                begin
                    colResume := White;
                    if (GetMouseButtons = 1) then
                    begin
                        PutAnim(0, spdBg, animVoid, BkgPut);
                        exit;
                    end;
                end
                else if (GetMouseY > yToMenu - 10) and (GetMouseY < yToMenu + lineHeight + 10) then
                begin
                    colToMenu := White;
                    if GetMouseButtons = 1 then
                    begin
                        ext := true;
                        exit;
                    end;
                end;
            end;
            SetColor(colResume);
            OutTextXY(xResume, yResume, 'Resume');
            SetColor(colToMenu);
            OutTextXY(xToMenu, yToMenu, 'To main menu');
            if (KeyPressed) then
            begin
                key := ReadKey;
            end;
            UpdateGraph(UpdateNow);
            delay(3);
    until (key = esc);

    PutAnim(0, 0+spdBg, animVoid, BkgPut);
end;

procedure GameOver(strScore : string);
var
colTryAgain, colToMenu : longint;
earnedCoins : byte;
lineHeight,
yCarIsDestroyed, yScore, yEarnedCoins, yTryAgain, yToMenu
: integer;
strEarnedCoins : string[6];
begin
    SetTextStyle(1, 0, 4);
    lineHeight := TextHeight('ABC');
    yCarIsDestroyed := GetMaxY div 2 - lineHeight * 4 - 5;
    yScore := yCarIsDestroyed + lineHeight * 2;
    yEarnedCoins := yScore + lineHeight + 5;
    yTryAgain := yEarnedCoins + lineHeight * 2;
    yToMenu := yTryAgain + lineHeight * 2;
    earnedCoins := 2 * lvl;
    coins := coins + earnedCoins;
    Str(earnedCoins, strEarnedCoins);
    Str(score, strScore);
    Str(highscore, strHighscore);
    if (score > highscore) then
    begin
    	highscore := score;
    end;
    spdBg := 7;
    for i:=1 to K do
    begin
        if (policeMoving[i]) then
        begin
            policeMoving[i] := false;
        end;
    end;
    PutAnim(xCar, yCar, animCar, BkgPut);
    PutAnim(xCar, yCar, animCarBroken, TransPut);
    repeat
            RoadMove;
            PutAnim(xCar, yCar, animCarBroken, BkgPut);
            yCar := yCar + spdBg;
            PutAnim(xCar, yCar, animCarBroken, TransPut);
            UpdateGraph(UpdateNow);
            Delay(5);
    until (yCar >= GetMaxY);

    repeat
        RoadMove;
        SetFillStyle(1, Black);
        Bar(GetMaxX div 2 - TextWidth('AAAAAAAAAAAAAA'), yCarIsDestroyed - lineHeight, GetMaxX div 2 + TextWidth('AAAAAAAAAAAAAA'), yToMenu + lineHeight * 2);
        SetFillStyle(1, Yellow);
        Bar(GetMaxX div 2 - TextWidth('AAAAAAAAAAAAAA'), yCarIsDestroyed - lineHeight + 5, GetMaxX div 2 + TextWidth('AAAAAAAAAAAAAA'), yToMenu + lineHeight * 2 - 5);
        colTryAgain := Black;
        colToMenu := Black;
        if (GetMouseX > GetMaxX div 2 - TextWidth('Back to menu')) and (GetMouseX < GetMaxX div 2 + TextWidth('Back to menu')) then
        begin
            if (GetMouseY > yTryAgain - 5) and (GetMouseY < yTryAgain + lineHeight + 5) then
            begin
            	colTryAgain := White;
                if (GetMouseButtons = 1) then
                begin
                	cntinue := true;
                exit;
                end;
            end
            else
            if (GetMouseY > yToMenu - 5) and (GetMouseY < yToMenu + lineHeight + 5) then
            begin
            	colToMenu := White;
                if (GetMouseButtons = 1) then
                begin
                	ext := true;
                exit;
                end;
            end;
        end;
        SetColor(Black);
        OutTextXy(GetMaxX div 2 - TextWidth('Your car is destroyed.') div 2, yCarIsDestroyed, 'Your car is destroyed.');
        OutTextXy(GetMaxX div 2 - TextWidth('Score: ' + strScore + '. Current highscore is ' + strHighscore + '.') div 2, yScore, 'Score: ' + strScore + '. Current highscore is ' + strHighscore + '.');
        OutTextXy(GetMaxX div 2 - TextWidth(strEarnedCoins + ' coins earned.') div 2, yEarnedCoins, strEarnedCoins + ' coins earned.');
        SetColor(colToMenu);
        OutTextXY(GetMaxX div 2 - TextWidth('To main menu') div 2, yToMenu, 'To main menu');
        SetColor(colTryAgain);
        OutTextXY(GetMaxX div 2 - TextWidth('Try again') div 2, yTryAgain, 'Try again');
        UpdateGraph(UpdateNow);
        Delay(5);
        PutAnim(0, spdBg, animVoid, BkgPut);
    until false;
end;

procedure Game;
var hpCar : integer;
begin;
    InitData;
    hpCar := 500;
    carIsVisible := true;
    newSuv := Random(20) + 200;
    cntinue := false;
    isDamageResist := false;
    cDamageresist := 0;

    ClearDevice;
    PutImage(0, 0, pointerBg^, 0);
    PutAnim(getmaxx div 2 - 340, yBg, animRoad, TransPut);
    PutAnim(xCar, yCar, animCar, TransPut);

    repeat
        SelfMove(xCar, yCar, 0, -5, animCar);
        UpdateGraph(UpdateNow);
        Delay(8);
    until (yCar <= yCarStd);

    repeat
        if (carIsVisible) then
        begin
            PutAnim(xCar, yCar, animCar, BkgPut);
        end;
        PoliceTiming;
        for i:=1 to k do
        begin
            if policeMoving[i] then
            begin
                PutAnim(xPolice[i], yPolice[i], animPolice[i], BkgPut);
                if not(isDamageResist) then
                    if ((abs((xCar + wdhCar div 2) - (xPolice[i] + wdhPolice[i] div 2)) - (wdhCar div 2 + wdhPolice[i] div 2)) <= 0) then
                    begin
                        if ((abs((yCar + hgtCar div 2) - (yPolice[i] + hgtPolice[i] div 2)) - (hgtCar div 2 + hgtPolice[i] div 2)) <= 0) then
                        begin
                            policeMoving[i] := false;
                            PutAnim(xPolice[i], yPolice[i], animPoliceBroken[i], TransPut);
                            hpCar := hpCar - 100;
                            isDamageResist := true;
                        end;
                end;
                if (yPolice[i] > GetMaxY) then
                begin
                	policeMoving[i] := false;
                    score := score + 2;
                end;
            end;
        end;
        if (isDamageResist) then
        begin
            DamageResist;
        end;
        Str(score, strScore);
        RoadMove;
        if (warning) then
        begin
        	PutAnim(xWarn, 0, animWarn, TransPut);
        end;
        for i:=1 to k do
        begin
            if policeMoving[i] then
            begin
                PoliceMove(xPolice[i], yPolice[i], xDirt[i], spdxPolice[i], spdyPolice[i], animPolice[i]);
            end;
        end;
        if (KeyPressed) then
        begin
            CarMove;
        end;
        if (carIsVisible) then
        begin
            PutAnim(xCar, yCar, animCar, TransPut);
        end;
        UI(hpCar, strScore);
        //if (GetMouseX > 2) and (GetMouseY > 20) then
        //begin
        //    SetMouseXY(GetmouseX - 3, GetMouseY - 25);
        //    SetMouseXY(GetmouseX - 3, GetMouseY - 26);
        //end;
        lvl := 1 + score div 10;
        spdBg := 7 + lvl;
        if (GetMouseButtons = 1) then
        begin
            if not(mouseHold) then
            begin
                MouseClick;
            end;
        end
        else
        begin
            mouseHold := false;
        end;
        if (key = esc) then
        begin
            Pause;
            if (ext) then
            begin
                exit;
            end;
        end;
        UpdateGraph(UpdateNow);
        Delay(1);
    until (hpCar <= 0);

    GameOver(strScore);
end;

procedure Button(xText, yText, indent : integer; text : string);
begin
	SetFillStyle(1, Black);
    Bar(xText - indent, yText - indent, xText + TextWidth(text) + indent, yText + TextHeight(text) + indent);
    SetFillStyle(1, Yellow);
    Bar(xText - indent + 3, yText - indent + 3, xText + TextWidth(text) + indent - 3, yText + TextHeight(text) + indent - 3);
end;

procedure MenuCarTiming;
begin
    cCarmenu := cCarmenu + 1;
    if not(carMenu) and (cCarmenu >= newCarMenu) then
    begin
        carMenu := true;
        xCar := GetMaxX-140;
        yCar := GetMaxY;
        PutAnim(xCar, yCar, animCar, TransPut);
        cCarMenu := 0;
        newCarMenu := Random(500)+1000;
    end;
end;

procedure TextParagraph(xParagraph, yParagraph, maxWidth : integer; fileName : string);
var
textFile : text;
lines : array[1..100] of string;
widthOfLongestLine, paragraphWidth, paragraphHeight : integer;
lineNumber, ySpace, l : byte;
nextChar : char;
begin
    for i := 1 to 100 do
    	lines[i] := '';
    lineNumber := 1;
    widthOfLongestLine := 0;
    ySpace := TextHeight('ABC') div 4;
    SetColor(Black);
    Assign(textFile, fileName);
    if FileExists(fileName) then
    begin
        Reset(textFile);
        while not Eof(textFile) do
        begin
            Read(textFile, nextChar);
            if (TextWidth(lines[lineNumber]) > maxWidth) and (nextChar = ' ') then
            begin
                if (TextWidth(lines[linenumber]) > widthOfLongestLine) then
                begin
                	widthOfLongestLine := TextWidth(lines[linenumber]);
                end;
                Read(textFile, nextChar);
                lineNumber := lineNumber + 1;
            end;
            lines[lineNumber] := lines[lineNumber] + nextChar;
        end;
        Close(textFile);
        paragraphWidth := widthOfLongestLine + 10;
        paragraphHeight := TextHeight('ABC') * lineNumber + ySpace * (lineNumber - 1) + 10;
        SetFillStyle(1, Black);
        Bar(xParagraph, yParagraph, xParagraph + paragraphWidth, yParagraph + paragraphHeight);
        SetFillStyle(1, Yellow);
        Bar(xParagraph + 3, yParagraph + 3, xParagraph + paragraphWidth - 3, yParagraph + paragraphHeight - 3);
        for l := 1 to lineNumber do
        begin
            OutTextXY(xParagraph + paragraphWidth div 2 - TextWidth(lines[l]) div 2, yParagraph + 5 + (l - 1) * (TextHeight('ABC') + ySpace), lines[l]);
        end;
    end;
end;


procedure Tutorial;
var
cheatString : string;
strKey : string;
begin
    cheatstring := '';

    PutImage(0, 0, pointerBg^, 0);
    repeat
    until (GetMouseButtons <> 1);
    SetTextStyle(1, 0, 4);
    TextParagraph(GetMaxX div 2 - 190, GetMaxY div 2 - 200, 300, 'Tutorial.pas');
    UpdateGraph(UpdateNow);
    repeat
		Delay(1);
    until (GetMouseButtons = 1);
    repeat
    until (GetMouseButtons <> 1);

    PutImage(0, 0, pointerBg^, 0);
    PutAnim(GetMaxX div 2 - 340, 0, animRoad, TransPut);
    PutAnim(xCarStd, yCarStd, animCar, TransPut);
    TextParagraph(xCarStd + wdhCar + 20, yCarStd - 100, 280, 'Car.pas');
    UpdateGraph(UpdateNow);
    repeat
		Delay(1);
    until (GetMouseButtons = 1);
    repeat
    until (GetMouseButtons <> 1);

    PutImage(0, 0, pointerBg^, 0);
    PutAnim(GetMaxX div 2 - 340, 0, animRoad, TransPut);
    PutAnim(xCarStd, yCarStd, animCar, TransPut);
    PutAnim(GetMaxX div 4 - 200, GetMaxY div 4, animPoliceL[1], TransPut);
    TextParagraph(GetMaxX div 4 - 200, GetMaxY div 4 + 64, 250, 'PoliceCars.pas');
    UpdateGraph(UpdateNow);
    repeat
		Delay(1);
    until (GetMouseButtons = 1);
    repeat
    until (GetMouseButtons <> 1);

    PutImage(0, 0, pointerBg^, 0);
    PutAnim(GetMaxX div 2 - 340, 0, animRoad, TransPut);
    PutAnim(xCarStd, yCarStd, animCar, TransPut);
    PutAnim(GetMaxX div 4 - 200, GetMaxY div 4, animPoliceL[1], TransPut);
    PutAnim(GetMaxX div 2 + 360, GetMaxY div 2, animPoliceR[1], TransPut);
    PutAnim(xCarStd, 0, animWarn, TransPut);
    TextParagraph(xCarStd + wdhCar + 10, 20, 250, 'Warnings.pas');
    UpdateGraph(UpdateNow);
    repeat
		Delay(1);
    until (GetMouseButtons = 1);
    repeat
    until (GetMouseButtons <> 1);

    PutImage(0, 0, pointerBg^, 0);
    PutAnim(GetMaxX div 2 - 340, 0, animRoad, TransPut);
    PutAnim(xCarStd, yCarStd, animCar, TransPut);
    PutAnim(GetMaxX div 4 - 200, GetMaxY div 4, animPoliceL[1], TransPut);
    PutAnim(GetMaxX div 2 + 360, GetMaxY div 2, animPoliceR[1], TransPut);
    PutAnim(xCarStd, 100, animPoliceSuv, TransPut);
    TextParagraph(xCarStd + wdhCar + 10, 20, 250, 'Suvs.pas');
    UpdateGraph(UpdateNow);
    repeat
		Delay(1);
    until (GetMouseButtons = 1);
    repeat
    until (GetMouseButtons <> 1);

    PutImage(0, 0, pointerBg^, 0);
    PutAnim(GetMaxX div 2 - 340, 0, animRoad, TransPut);
    PutAnim(xCarStd, yCarStd, animCar, TransPut);
    PutAnim(GetMaxX div 4 - 200, GetMaxY div 4, animPoliceL[1], TransPut);
    PutAnim(GetMaxX div 2 + 360, GetMaxY div 2, animPoliceR[1], TransPut);
    PutAnim(xCarStd, 100, animPoliceSuv, TransPut);
    UI(500, '777');
    TextParagraph(TextWidth('777') + 10, yCarStd + 70, 250, 'Score.pas');
    TextParagraph(GetMaxX - 300, yCarStd + 70, 150, 'HPCar.pas');
    UpdateGraph(UpdateNow);
    repeat
		Delay(1);
        if (GetMouseX < TextWidth('777')) and (GetMouseY > GetMaxY - TextHeight('777')) then
        begin
            if (KeyPressed) then
            begin

                key := readkey;
                //Str(key, )
                case key of

                    AA:
                        begin
                            cheatString := cheatString + 'a';
                            writeln('a');
                        end;

                    ZZ:
                        begin
                            cheatString := cheatString + 'z';
                            writeln('z');
                        end;

                    II:
                        begin
                            cheatString := cheatString + 'i';
                            writeln('i');
                        end;

                    NN:
                        begin
                            cheatString := cheatString + 'n';
                            writeln('n');
                        end;

                    OO:
                        begin
                            cheatString := cheatString + 'o';
                            writeln('o');
                        end;

                end;
                writeln(cheatString);
            end;

            if (Length(cheatString) > 5) then
            begin
                cheatstring := '';
            end;

            if (cheatstring = 'azino') then

            //if (GetMouseButtons > 1) then
            begin
                coins := 9999;
            end;
        end;
    until (GetMouseButtons = 1);
    repeat
    until (GetMouseButtons <> 1);

    PutImage(0, 0, pointerBg^, 0);
    PutAnim(GetMaxX div 2 - 340, 0, animRoad, TransPut);
    PutAnim(xCarStd, yCarStd, animCar, TransPut);
    PutAnim(GetMaxX div 4 - 200, GetMaxY div 4, animPoliceL[1], TransPut);
    PutAnim(GetMaxX div 2 + 360, GetMaxY div 2, animPoliceR[1], TransPut);
    PutAnim(xCarStd, 100, animPoliceSuv, TransPut);
    UI(500, '777');
    TextParagraph(GetMaxX div 2 - 190, GetMaxY div 2 - 200, 300, 'TutorialEnd.pas');
    UpdateGraph(UpdateNow);
    repeat
		Delay(1);
    until (GetMouseButtons = 1);
    repeat
    until (GetMouseButtons <> 1);
    exit;
end;

procedure ItemDescription(i, j, yDescr : integer);
var
descrFile : text;
fileName, strI, strJ : string;
lines : array[1..15] of string;
lineNumber, l : byte;
nextChar : char;
ySpace : integer;
xDescrMiddle, yDescrMiddle : integer;
descrHeight : integer;
begin
    descrHeight := 0;
    xDescrMiddle := 0;
    xDescrMiddle := 50 + (GetMaxX - 600) div 2;
    yDescrMiddle := GetMaxY div 2 + 100 + (GetMaxY div 2 - 200) div 2;
    lineNumber := 1;
    for l := 1 to 15 do
    begin
    	lines[l] := ' ';
	end;
    SetTextStyle(1, 0, 4);
    SetColor(Black);
    Str(i, strI);
    Str(j, strJ);
    Assign(descrFile, strI + '_' + strJ + 'descr.pas');
    if (FileExists(strI + '_' + strJ + 'descr.pas')) then
    begin
        Reset(descrFile);
        while not Eof(descrFile) do
        begin
            Read(descrFile, nextChar);
            if (TextWidth(lines[lineNumber]) > GetMaxX - 700) and (nextChar = ' ') then
            begin
            	lineNumber := lineNumber + 1;
                Read(descrFile, nextChar);
            end;
            lines[lineNumber] := lines[lineNumber] + nextChar;
        end;
        ySpace := (GetMaxY div 2 - 210) div lineNumber - TextHeight('ABC');
        if (ySpace >= 30) then
        begin
			ySpace := 15;
        end;
        descrHeight := lineNumber * (TextHeight('ABC') + ySpace);

        for l := 1 to lineNumber do
        begin
            OutTextXY(xDescrMiddle - TextWidth(lines[l]) div 2, yDescrMiddle - descrHeight div 2 + yDescr + (l - 1) * (TextHeight('ABC') + ySpace), lines[l]);
        end;
        Close(descrFile);
    end;
end;

procedure ShopRoadMove(var yRoad : integer; animRoad1, animRoad2 : animattype);
begin
	PutAnim(GetMaxX - 500, yRoad, animRoad1, BkgPut);
    PutAnim(GetMaxX - 500, yRoad - hgtScreen, animRoad2, BkgPut);
    //PutImage(GetMaxX - 500, yRoad, pointerRoad, 0);
    //PutImage(GetMaxX - 500, yRoad - hgtScreen, pointerRoad, 0);
    yRoad := yRoad + 8;
    if (yRoad > hgtScreen) then
    begin
    	yRoad := 0;
    end;
    PutAnim(GetMaxX - 500, yRoad, animRoad1, TransPut);
    PutAnim(GetMaxX - 500, yRoad - hgtScreen, animRoad2, TransPut);
    PutAnim(xCar, yCar, animCar, Transput);
end;

procedure Shop;
var
xSpace, ySpace : integer; // Расстояние между товарами в магазине
xPrice, yPrice,
xCoins, yButtons, yDescr,
xSelectButton, xBuyButton : longint;    // Координаты для элементов интерфейса
xSelect, ySelect, xSelected, ySelected : integer;      // Координаты обводок, зеленой и оранжевой
yRoad : integer;
animRoad1, animRoad2 : animattype;
colBack, colRightButton : longint;
price, xSlot, ySlot : array[0..2, 1..3] of integer;
rightButton,
selRow, selCol : integer; // Строка и столбец выбранного слота
strPrice : string;
begin
    Str(coins, strCoins);
    SetTextStyle(1, 0, 4);
    yCar := GetMaxY div 2 - hgtCar div 2;
    animRoad1 := animRoad;
    animRoad2 := animRoad;
    PutImage(0, 0, pointerBg^, 0);
    PutAnim(GetMaxX - 500, 0, animRoad, TransPut);
    xSpace := (GetMaxX - 606 - 3 * 128) div 4;
    ySpace := (GetMaxY div 2 + 47 - 2 * 128) div 3;
    SetFillStyle(1, Black);
    Bar(50, 50, GetMaxX - 550, GetMaxY - 100);
    Bar(50, GetMaxY div 2 + 100, GetMaxX - 550, GetMaxY - 100);
    SetFillStyle(1, Yellow);
    Bar(53, 53, GetMaxX - 553, GetMaxY - 103);
    SetFillStyle(1, Black);
    Bar(50, GetMaxY div 2 + 100, GetMaxX - 550, GetMaxY - 100);
    SetFillStyle(1, Yellow);
    Bar(53, GetMaxY div 2 + 103, GetMaxX - 553, GetMaxY - 103);

    yDescr := GetMaxY div 2 + 105;
    yButtons := GetMaxY - 50 - TextHeight('Back to menu') div 2;
    xSelectButton := (GetMaxX - 560) - TextWidth('Select');
    xBuyButton := GetMaxX - (560 + (TextWidth('Select')  + TextWidth('Buy')) div 2);
    Button(60, yButtons, 10, 'Back to menu');
    Button(xSelectButton, yButtons, 10, 'Select');
    PutAnim(50 + TextWidth('Back to menu') + 45, GetMaxY - 82, animCoin, TransPut);
    PutAnim(50 + TextWidth('Back to menu') + 109, GetMaxY - 82, animCoin, TransPut);
    PutAnim(50 + TextWidth('Back to menu') + 109, GetMaxY - 82, animCoin, BkgPut);
    SetColor(Yellow);
    OutTextXY(166 + TextWidth('Back to menu'), GetMaxY - 48 - TextHeight(strCoins) div 2, strCoins);
    SetColor(Black);
    OutTextXY(164 + TextWidth('Back to menu'), GetMaxY - 50 - TextHeight(strCoins) div 2, strCoins);
	animSlot[1, 3] := animSlot3[upgradeLvl[1, 3]];

    for i := 1 to 2 do
    	for j := 1 to 3 do
    	begin
        	xSlot[i, j] := 53 + xSpace + (j - 1)*(128 + xSpace);
        	ySlot[i, j] := 53 + ySpace + (i - 1)*(128 + ySpace);
            PutAnim(xSlot[i, j], ySlot[i, j], animSlot[i, j], TransPut);
            if (i = 1) then
            begin
                price[1, j] := 15 + 10 * upgradeLvl[i, j];
            	if (j = 3) then
                begin
                	if (upgradeLvl[1, 3] < 2) then
                    begin
                    	price[i, j] := 100;
                    end;
                end;
                Str(price[1, j], strPrice);
                xPrice := xSlot[1, j] + 64 - TextWidth('Price: ' + strPrice + ' coins') div 2;
                yPrice := ySlot[1, j] + 130;
                OutTextXY(xPrice, yPrice, 'Price: ' + strPrice + ' coins');
            end;
    	end;

    repeat
        colRightButton := Black;
        colBack := Black;
        xSelect := GetMaxX;           // 		Принцип работы появляющейся обводки: каждый кадр координаты обводки сбрасываются,
        ySelect := GetMaxY;           // а при наведении(нажатии) мыши на товар обводке присваиваются координаты товара, где она и отрисовывается
        if (selRow > 0) and (selRow < 3) then
        begin
            PutAnim(xSlot[selRow, selCol] - 4, ySlot[selRow, selCol] - 4, animSelected, BkgPut);
        end;
        if (GetMouseY > yButtons - 10) and (GetMouseY < yButtons + TextHeight('ABC') + 10) then
        begin
        	If (GetMouseX > 50) and (GetMouseX < 70 + TextWidth('Back to menu')) then
            begin
                colBack := White;
                if GetMouseButtons = 1 then
                begin
                	break;
                end;
            end
            else if (GetMouseX > xSelectButton - 10) and (GetMouseX < GetMaxX - 550) and (upgradeLvl[selRow, selCol] < 5) then
            begin
                colRightButton := White;
                if not(mouseHold) and (GetMouseButtons = 1) then
                begin
                	if (selRow = 2) then
                    begin
                    	case selCol of

                        	1 :
                            begin
                            	animCar := animStdCar;
                                animCarBroken := animStdCarBroken;
                            end;

                            2 :
                            begin
                            	animCar := animF1;
                                animCarBroken := animF1Broken;
                            end;

                            3 :
                            begin
                            	animCar := animBigfoot;
                            	animCarBroken := animBigfootBroken;
                            end;

   						end;
                    end
                    else if (coins >= price[selRow, selCol]) then
                    begin
                    	xPrice := xSlot[selRow, selCol] + 64 - TextWidth('Price: ' + strPrice + ' coins') div 2;
                        yPrice := ySlot[selRow, selCol] + 130;
                        SetFillStyle(1, Yellow);
                        Bar(xPrice, yPrice, xPrice + TextWidth('Price: ' + strPrice + ' coins'), yPrice + TextHeight('ABC'));
                        coins := coins - price[selRow, selCol];
                        Str(coins, strCoins);
                        upgradeLvl[selRow, selCol] := upgradeLvl[selRow, selCol] + 1;
                        PutAnim(50 + TextWidth('Back to menu') + 109, GetMaxY - 82, animCoin, BkgPut);
    					SetColor(Yellow);
    					OutTextXY(166 + TextWidth('Back to menu'), GetMaxY - 48 - TextHeight(strCoins) div 2, strCoins);
    					SetColor(Black);
    					OutTextXY(164 + TextWidth('Back to menu'), GetMaxY - 50 - TextHeight(strCoins) div 2, strCoins);
                        price[selRow, selCol] := 15 + 10 * upgradeLvl[selRow, selCol];
                        Str(price[selRow, selCol], strPrice);
                        OutTextXY(xSlot[selRow, selCol] + 64 - TextWidth('Price: ' + strPrice + ' coins') div 2, ySlot[selRow, selCol] + 130, 'Price: ' + strPrice + ' coins');
                        if (selCol = 3) then
                        begin
                                  //a
                        end;
                    end;
                end;
            end;
        end
        else if not(mouseHold) and (GetMouseButtons = 1) then
        begin
        	for i := 1 to 2 do
    			for j := 1 to 3 do
    			begin
                	If not((GetMouseX > xSlot[i, j]) and (GetMouseX < xSlot[i, j] + 128)) then
                		if not((GetMouseY > ySlot[i, j]) and (GetMouseY < ySlot[i, j] + 128)) then
                    	begin
                    		selRow := 0;
                    	end;
                end;
        end;
        for i := 1 to 2 do
    		for j := 1 to 3 do
    		begin
                If ((GetMouseX > xSlot[i, j]) and (GetMouseX < xSlot[i, j] + 128)) then
                	if((GetMouseY > ySlot[i, j]) and (GetMouseY < ySlot[i, j] + 128)) then
            		begin
                        xSelect := xSlot[i, j] - 6;
                        ySelect := ySlot[i, j] - 6;
                        if not(mouseHold) and (GetMouseButtons = 1) then
                    	begin
                            selRow := i;
                        	selCol := j;
                            SetFillStyle(1, Black);
    						Bar(50, GetMaxY div 2 + 100, GetMaxX - 550, GetMaxY - 100);
    						SetFillStyle(1, Yellow);
    						Bar(53, GetMaxY div 2 + 103, GetMaxX - 553, GetMaxY - 103);
                            ItemDescription(i, j, yDescr);
                        end;
                        break;
                    end;
    		end;
        SetTextStyle(1, 0, 4);
        if not(rightButton = selRow) then
        begin
        	rightButton := selRow;
            Button(xSelectButton, yButtons, 10, 'Select');
        end;
        case rightbutton of

            1:
            begin
            	SetColor(colRightButton);
                OutTextXY(xBuyButton, yButtons, 'Buy');
            end;

            2:
            begin
                SetColor(colRightButton);
                OutTextXY(xSelectButton, yButtons, 'Select');
            end;

        end;

        if (selRow > 0) and (selRow < 3) then
        begin
        	PutAnim(xSlot[selRow, selCol] - 4, ySlot[selRow, selCol] - 4, animSelected, TransPut);
        end;
		PutAnim(xSelect, ySelect, animSelect, TransPut);

        SetColor(colBack);
        OutTextXY(60, yButtons, 'Back to menu');

        if (GetMouseButtons = 1) then
        begin
            if not(mouseHold) then
            begin
                mouseHold := true;
            end;
        end
        else
        begin
            mouseHold := false;
        end;

        ShopRoadMove(yRoad, animRoad1, animRoad2);
        UpdateGraph(UpdateNow);
    	Delay(10);
        PutAnim(xSelect, ySelect, animSelect, BkgPut);
    until GetMouseButtons = 2;
    repeat
    	yCar := yCar + 8;
        ShopRoadMove(yRoad, animRoad1, animRoad2);
        UpdateGraph(UpdateNow);
    	Delay(10);
    until (yCar >= GetMaxY);
    cCarMenu := 9999;
end;

procedure Menu;
var
colStart, colAbout, colQuit, colShop, colClearProgress : longint;
yPoliceCar, yStart, yAbout, yQuit, xShop, yShop, xClearProgress, yClearProgress,
ySpace, xMenuList : integer;
xCoins : integer;
saveFile : Text;
begin
    key := ' ';
    Str(coins, strCoins);
    Str(highscore, strHighscore);
    carMenu := false;

    ClearDevice;
    PutImage(0, 0, pointerBg^, 0);
    PutAnim(GetMaxX - 500, 0, animRoad, TransPut);
    repeat
    until (GetMouseButtons <> 1);
    SetTextStyle(1, 0, 4);
    SetFillStyle(1, Black);
    Bar(50, GetMaxY - 550, 440, GetMaxY - 50);
    SetFillStyle(1, Yellow);
    Bar(53, GetMaxY - 547, 437, GetMaxY - 53);
    SetColor(Black);
    yPoliceCar := 70 + TextHeight('Shop') + (GetMaxY - 550 - (70 + TextHeight('Shop'))) div 2 - wdhCar div 2;
    PutAnim(480, yPoliceCar + 4, animDirt, TransPut);
    PutAnim(500, yPoliceCar, animPoliceLBroken, TransPut);

    xClearProgress := 510;
    yClearProgress := GetMaxY - 60 - TextHeight('ABC');
    ySpace := (494 - 4 * TextHeight('ABC')) div 5;
    xMenuList := 100;
    yStart := GetMaxY - 547 + ySpace * 2 + TextHeight('ABC');
    yAbout := GetMaxY - 547 + ySpace * 3 + TextHeight('ABC') * 2;
    yQuit := GetMaxY - 547 + ySpace * 4 + TextHeight('ABC') * 3;
    xShop := 50 + (TextWidth('Shop') + 30) div 2 - TextWidth('Shop') div 2;
    yShop := 60;
	xCoins := xShop + TextWidth('Shop') + 40;

    Button(xClearProgress, yClearProgress, 10, 'Clear Progress');
    Button(xShop, yShop, 15, 'Shop');
    PutAnim(xCoins, yShop + 10, animCoin, TransPut);
    SetColor(Yellow);
    OutTextXY(xCoins + 73, yShop + 41 - TextHeight(strCoins) div 2, strCoins);
    OutTextXY(480, yPoliceCar + 64, 'Highscore: ' + strHighscore);
    SetColor(Black);
    OutTextXY(482, yPoliceCar + 65, 'Highscore: ' + strHighscore);
    OutTextXY(xCoins + 75, yShop + 42 - TextHeight(strCoins) div 2, strCoins);
    OutTextXY(xMenuList, GetMaxY - 547 + ySpace, 'MAIN MENU');
    repeat
        if carMenu then
        begin
            SelfMove(xCar, yCar, 0, -5, animCar);
            if (yCar < -hgtCar) then
                carMenu := false;
        end;
        colClearProgress := Black;
        colStart := Black;
        colAbout := Black;
        colQuit := Black;
        colShop := Black;
        if (GetMouseX > 80) and (GetMouseX < 410) then
        begin
            if (GetMouseY > yStart - 10) and (GetMouseY < yStart + 10 + TextHeight('Start')) then
            begin
                colStart := White;
                if GetMouseButtons = 1 then
                begin
                    repeat
                        Game;
                    until cntinue = false;
                    ext := false;
                    exit;
                end;
            end
            else if (GetMouseY > yAbout - 10) and (GetMouseY < yAbout + 10 + TextHeight('Tutorial')) then
            begin
                colAbout := White;
                if GetMouseButtons = 1 then
                begin
                    Tutorial;
                    exit;
                end;
            end
            else if (GetMouseY > yQuit - 10) and (GetMouseY < yQuit + 10 + TextHeight('Quit')) then
            begin
                colQuit := White;
                if GetMouseButtons = 1 then
                begin
                	SaveGame;
                    halt;
                end;
            end;
        end;
        if (GetMouseX > xShop - 10) and (GetMouseX < xShop + TextWidth('Shop') + 10) then
            if (GetMouseY > yShop - 10) and (GetMouseY < yShop + TextHeight('Shop') + 10) then
            	begin
                    colShop := White;
                	if GetMouseButtons = 1 then
                    begin
                		Shop;
                        exit;
                    end;
                end;
        if (GetMouseX > xClearProgress - 10) and (GetMouseX < xClearProgress + TextWidth('Clear progress') + 10) then
            if (GetMouseY > yClearProgress - 10) and (GetMouseY < yClearProgress + TextHeight('ABC') + 10) then
            begin
            	colClearProgress := White;

                if (GetMouseButtons = 1) then
                begin
                    Assign(saveFile, 'Save.pas');
                    if (FileExists('Save.pas')) then
                    begin
                    	Erase(saveFile);
                    end;
                    LoadSavedGame;
                    exit;
                end;
            end;
        SetColor(colClearProgress);
        OutTextXY(xClearProgress, yClearProgress, 'Clear Progress');
        SetColor(colStart);
        OutTextXY(xMenuList, yStart, 'Start');
        SetColor(colAbout);
        OutTextXY(xMenuList, yAbout, 'Tutorial');
        SetColor(colQuit);
        OutTextXY(xMenuList, yQuit, 'Quit');
        SetColor(colShop);
        OutTextXY(xShop, yShop, 'Shop');
        UpdateGraph(UpdateNow);
        Delay(7);
        MenuCarTiming;
    until false;
end;

begin
    Randomize;
    gm := mfullscr;
    gd := nopalette;
    InitGraph (gd,gm,'');
    UpdateGraph(UpdateOff);
    Loading;
    repeat
        Menu;
    until false;
    CloseGraph;
end.
