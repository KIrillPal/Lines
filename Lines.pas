uses GraphABC,Events,Timers;
type Tballs= set of integer;
     Tball=array[1..2] of integer;
const
  WIDTH=1200;
  HEIGHT=730;
  MIN_LINE=5;
  COLOR_COUNT=6;
  NEW_BALLS=3;
  BT_RADIUS=35;
var 
  n,i,selected,score,b_lb,b_rb,b_p,b_bk,d_b1,d_b2,steps,isgame,points,dialogType,BAR_WIDTH,BAR_TOP,ITEM_SIZE,BALL_SIZE, LAST_RECORD: integer;
  pop,song,boom,torecord: system.Media.SoundPlayer;
  starts:array[1..4] of string=('Start-Poslala.wav','Start-Engine.wav','Start-Gong.wav','Start-Oracle.wav');
  ends:array[1..6] of string=('Ow-Cuckoo.wav','Ow-No.wav','Ow-Noo.wav','Ow-Uh-oh.wav','Ow-Male-04.wav','Ow-Car.wav');
  field:array[0..255, 0..255] of integer;
  status_img1,status_img2,status_img3,status_img4: Picture;
  ltcr,dkcr:byte;
  ballexists,isbig:boolean;
  dead,sizes:array[0..16383] of shortint;
  next:array[1..3] of Tball=((-1,-1),(-1,-1),(-1,-1));
  balls: array[1..COLOR_COUNT] of Tballs;
  btd1,btd2: array[1..4] of integer;
  colors: array[1..6] of Color=(clRed,clGreen,clBlue,rgb(231, 216, 23),rgb(187, 53, 111),clBlack);
  phantoms:set of integer;
  time: Timer;
function findcolor(index:integer):Color;
var i:integer;
begin
  result:=clMagenta;
  for i:=1 to COLOR_COUNT do
  if index in balls[i] 
    then result:=colors[i];
  ballexists:=(result<>clMagenta);
end;
procedure CreateDialog(heading,maintext,button1,button2:string;d:integer);
const heg=150; wid=300; head=26;
var i,x,y:integer;
begin
  dialogType:=d;
  isgame:=2;
// Тело
  SetBrushColor(clWhite);
  x:=WIDTH-(HEIGHT+wid)div 2;
  y:=HEIGHT-(HEIGHT+heg)div 2;
  FillRect(x,y,x+wid,y+heg);
  SetFontColor(clBlack);
  SetFontSize(10);
// Тексты
  SetBrushColor(rgb(248,248,248));
  FillRect(x,y,x+wid,y+head);
  TextOut(x+5,y+5,heading);
  SetFontSize(10);
  SetBrushColor(clWhite);
  TextOut(x+head+5,y+head+15,maintext);
  if d<>3 
  then SetFontSize(16)
  else SetFontSize(8);
// Кнопка закрытия
  SetBrushColor(rgb(220,200,200));
  FillRect(x+wid-head,y,x+wid,y+head);
  SetPenColor(clWhite);
  Line(x+wid-head+7,y+7,x+wid-7,y+head-7);
  Line(x+wid-7,y+7,x+wid-head+7,y+head-7);
// Кнопка ОК
  SetBrushColor(rgb(91,172,234));
  FillRoundRect(x+wid-100-8,y+heg-40-8,x+wid-8,y+heg-8,3,3);
  TextOut(x+wid-50-4-round(length(button2)*(6.6-ord(d=3)*3.6)),y+heg-30-8,button2);
  btd2[1]:=x+wid-100-8; btd2[2]:=y+heg-40-8; 
  btd2[3]:=x+wid-8; btd2[4]:=y+heg-8;
// Кнопка Отмены
  SetBrushColor(rgb(91,172,234));
  FillRoundRect(x+wid-200-12,y+heg-40-8,x+wid-100-12,y+heg-8,3,3);
  TextOut(x+wid-150-8-round(length(button1)*(6.6-ord(d=3)*3.6)),y+heg-30-8,button1);
  btd1[1]:=x+wid-200-12; btd1[2]:=y+heg-40-8; 
  btd1[3]:=x+wid-100-12; btd1[4]:=y+heg-8;
end;
procedure InitItem(index:integer);
const l=0.9;m=0.85;
var i,j,x,y,k:integer;
col:Color;
begin
// Отрисовка клетки
  i:=index div n;
  j:=index mod n;
  if not (((n mod 2=0)and(i mod 2=0)) xor (index mod 2=0)) then begin
    SetPenColor(rgb(ltcr,ltcr,ltcr));
    SetBrushColor(rgb(ltcr,ltcr,ltcr));
  end
  else begin
    SetPenColor(rgb(dkcr,dkcr,dkcr));
    SetBrushColor(rgb(dkcr,dkcr,dkcr));
  end;
  y:=BAR_TOP+i*ITEM_SIZE;
  x:=BAR_WIDTH+j*ITEM_SIZE;
  Rectangle(x,y,x+ITEM_SIZE,y+ITEM_SIZE);
  
// Отрисовка круга выделения
  col:=findcolor(index);
  if ballexists then begin
    x:=x+(ITEM_SIZE div 2);
    y:=y+(ITEM_SIZE div 2);
    if selected=index then begin
 // Отрисовка мяча
      if ((n mod 2=0)and(i mod 2=0)) xor (j mod 2=0) then begin
        SetPenColor(rgb(round(ltcr*l),round(ltcr*l),round(ltcr*l)));
        SetBrushColor(rgb(round(ltcr*l),round(ltcr*l),round(ltcr*l)));
      end
      else begin
        SetPenColor(rgb(round(dkcr*l),round(dkcr*l),round(dkcr*l)));
        SetBrushColor(rgb(round(dkcr*l),round(dkcr*l),round(dkcr*l)));
      end;
      i:=(ITEM_SIZE+BALL_SIZE+5)div 4;
      Ellipse(x-i,y-i,x+i,y+i);
    end;
    SetPenColor(col);
    SetBrushColor(col);
    i:=BALL_SIZE div 2;
    Ellipse(x-i,y-i,x+i,y+i);
  end else begin
    for k:=1 to NEW_BALLS do
      if i*n+j=next[k,1] then begin
        x:=x+(ITEM_SIZE div 2);
        y:=y+(ITEM_SIZE div 2);
        col:=rgb(
          colors[next[k,2]].R+round((PenColor.R-colors[next[k,2]].R)*m),
          colors[next[k,2]].G+round((PenColor.G-colors[next[k,2]].G)*m),
          colors[next[k,2]].B+round((PenColor.B-colors[next[k,2]].B)*m)
        );
        SetPenColor(col);
        SetBrushColor(col);
        i:=BALL_SIZE div 2;
        Ellipse(x-i,y-i,x+i,y+i);
      end;
  end;
end;
procedure DrawButton(x,y,br,r:integer;col:Color);
begin
  var d:=2;
    SetBrushColor(rgb(87,87,87));
    FillEllipse(x-br-d,y-br-d,x+br+d,y+br+d);
    SetBrushColor(col);
    FillEllipse(x-br,y-br,x+br,y+br);
    SetPenColor(clWhite);
  // Треугольник
    if r<>0 then begin
      Line(x-r,y-round(sqrt(3)*r),x-r,y+round(sqrt(3)*r));
      Line(x-r,y-round(sqrt(3)*r),x+2*r,y);
      Line(x-r,y+round(sqrt(3)*r),x+2*r,y);
      FloodFill(x,y,clWhite);
    end;
end;
procedure DrawInfoRect(x,y,w,f:integer;s:string;texcol,outcol:Color);
begin
  SetFontSize(f);
  SetFontColor(texcol);
  SetBrushColor(outcol);
  FillRoundRect(x,y,x+w,y+26,10,10);
  TextOut(x+5,y+4,s);
end;
procedure ChangeSingle();
var i,k,h1,h2:integer; p:double;
begin
    inc(steps);
    SetFontSize(21);
    SetFontColor(clWhite);
    SetBrushColor(rgb(80,80,80));
    k:=steps;
    while k div round(exp(ln(10)*i))>0 do
      inc(i);
    var d:=(i-1)*6;
  // Область отрисовки шагов
    FillEllipse(bar_width div 2-BT_RADIUS-d,BAR_TOP+190,bar_width div 2+BT_RADIUS-d,BAR_TOP+190+2*BT_RADIUS);
    FillEllipse(bar_width div 2-BT_RADIUS+d,BAR_TOP+190,bar_width div 2+BT_RADIUS+d,BAR_TOP+190+2*BT_RADIUS);
    FillRect(bar_width div 2-d,BAR_TOP+190,bar_width div 2+d,BAR_TOP+190+2*BT_RADIUS);
    TextOut(bar_width div 2-round(1.5*d)-8,BAR_TOP+190+BT_RADIUS-15,steps);
    if score/last_record<0.25 then begin
  // Простая отрисовка очков
      DrawButton(bar_width-bar_width div 5,BAR_TOP+190+BT_RADIUS,BT_RADIUS,0,rgb(57, 206, 70));
      SetPenColor(clBlack);
      SetFontColor(clBlack);
      if (score>=0)and(score<10) then TextOut(bar_width-bar_width div 5-8,BAR_TOP+190+BT_RADIUS-16,score)
      else if (score>=10)and(score<100) then TextOut(bar_width-bar_width div 5-16,BAR_TOP+190+BT_RADIUS-16,score);
    end else begin
      if not isbig then begin
        //torecord.Play;
        isbig:=true;
      end;
  // Сложная отрисовка очков
      SetBrushColor(rgb(105,105,105));
      FillRect(bar_width-bar_width div 5-BT_RADIUS-2,BAR_TOP+188,bar_width-bar_width div 5+BT_RADIUS+2,BAR_TOP+192+2*BT_RADIUS);
      p:=HEIGHT div 2;
      for i:=255 downto 105 do begin
        SetBrushColor(rgb(i,105,105));
        FillRect(10,HEIGHT div 2+round(p)-10,BAR_WIDTH-10,HEIGHT div 2+round(p-(1/302)*HEIGHT)-10);
        p:=p-(1/302)*HEIGHT;
      end;
      h1 := HEIGHT - round(score*HEIGHT/(2*LAST_RECORD));
      h2 := HEIGHT div 2;
      if (h1 < h2)then begin
        h1 := HEIGHT div 2;
        h2 := HEIGHT - round(LAST_RECORD*HEIGHT/(2*score)); 
      end;
      // Противник
      SetBrushColor(rgb(255,55,55));
      FillRect(BAR_WIDTH - BAR_WIDTH div 5+5,HEIGHT-15,BAR_WIDTH-15,h2);
      SetBrushColor(rgb(65,58,58));
      
      FillRect(15,HEIGHT-15,BAR_WIDTH div 5-5,h1);
      i:=0; k:=score;
      while k div round(exp(ln(10)*i))>0 do
        inc(i);
      d:=(i-1)*6; var m:=3;
      SetFontColor(clBlack);
      SetBrushColor(rgb(57, 206, 70));
      FillEllipse(bar_width div 2-BT_RADIUS+m-d,BAR_TOP+190+2*BT_RADIUS+5+m,bar_width div 2+BT_RADIUS-m-d,BAR_TOP+190+4*BT_RADIUS-m+5);
      FillEllipse(bar_width div 2-BT_RADIUS+m+d,BAR_TOP+190+2*BT_RADIUS+5+m,bar_width div 2+BT_RADIUS-m+d,BAR_TOP+190+4*BT_RADIUS-m+5);
      FillRect(bar_width div 2-d+m,BAR_TOP+190+2*BT_RADIUS+5+m,bar_width div 2+d-m,BAR_TOP+190+4*BT_RADIUS+5-m);
      TextOut(bar_width div 2-round(1.5*d)-8,BAR_TOP+190+3*BT_RADIUS-10,score);
      
      DrawInfoRect(BAR_WIDTH div 5,h1,32,12,'Вы',rgb(175, 223, 255),rgb(80,80,80));
      DrawInfoRect(BAR_WIDTH - BAR_WIDTH div 5-80,h2,80,12,'Last User',rgb(175, 223, 255),rgb(80,80,80));
      DrawInfoRect(BAR_WIDTH div 2-length(LAST_RECORD.ToString)*6,h2,length(LAST_RECORD.ToString)*12,12,LAST_RECORD.ToString,rgb(175, 223, 255),rgb(80,80,80));
    end;
end;
function CountLine(var group,del:set of integer; x,y,dx,dy:integer):integer;
begin
  while ((y*n+x) in group)and(x>=0)and(y>=0)and(x<=n)and(y<=n) do begin
    del+=[y*n+x];
    x:=x+dx;
    y:=y+dy;
    inc(result);
  end;
end;
function CheckItem(index:integer):boolean;
var i,j,k,dx,dy,combo,sum,s:integer; col:color; del,alldel:set of integer;
begin
  alldel:=[];
  i:=index div n;
  j:=index mod n;
  col:=findcolor(index);
  for k:=1 to COLOR_COUNT do
      if col=colors[k] then break;
// Считаем линии
  for dx:=-1 to 0 do
    for dy:=-1 to 1 do begin
      if (dx=0)and(dy<>-1)or(dy=0)and(dx=0) then
        continue;
      del:=[];
      s:=CountLine(balls[k],del,j,i,dx,dy)+CountLine(balls[k],del,j,i,-dx,-dy)-1;
      if s>=MIN_LINE then begin
        inc(combo);
        if s=MIN_LINE*2-1 
          then inc(combo);
        sum:=sum+s;
        alldel+=del;
      end;
    end;
  if combo>0 then begin
  // Удаляем линии
    balls[k]-=alldel;
    if selected in alldel then
      selected:=-1;
    foreach s in alldel do begin
      dead[s]:=k;
      sizes[s]:=BALL_SIZE div 2;
      phantoms+=[s];
    end;
    time.Start;
    boom.Play;
    score:= score + combo*sum;
    points:=points+sum;
    ChangeSingle;
    result:=true;
  end;
end;
{function moveTo(j,i:integer):boolean;
begin
  if (i < 0) or (j < 0) or (i >= n) or (j >= n)
    then exit;
  if field[i][j] = 2
    then result := true
  else if field[i][j] = 1
    then result := false
  else begin
    field[i][j] := 1;
    result := 
    (moveTo(j-1, i) or
    moveTo(j+1, i) or
    moveTo(j, i-1) or
    moveTo(j, i+1));
    field[i][j] := 0;
  end;
  if result
      then field[i][j] := 2
      else field[i][j] := 1;
end;}
function CanMoveTo(x,y:integer):boolean;
var i,j:integer;
begin
  {for i:=0 to n do
    for j:=0 to n do begin
      findcolor(i*n+j);
      if ballexists
        then field[i][j] := 1
        else field[i][j] := 0;
    end;
  field[selected div n][selected mod n] := 0;
  field[y][x] := 2;
  result := moveTo(selected mod n, selected div n);  }
  result := true;
end;
function GetRandomBall():Tball;
var r,i,c:integer; b:boolean; test:Tballs;
begin
  test:=[];
  if points-NEW_BALLS > 0 then begin
    for i:=1 to COLOR_COUNT do
      test+=balls[i];
    repeat
      b:=true;
      r:=random(sqr(n)-1);
      for i:=1 to NEW_BALLS do
        if r=next[i,1] then
          b:=false;
    until not(r in test)and b;
    dec(points);
    result[1]:=r;
    result[2]:=random(1,COLOR_COUNT);
  end else result[1]:=-1;
end;
procedure GiveUp();
var i,x,y:integer;
begin
  ltcr:=53; dkcr:=43; isgame:=3;
  for i:=1 to COLOR_COUNT-1 do
    balls[i]:=[];
  balls[COLOR_COUNT]:=[0..sqr(n)-1];
  for i:=0 to sqr(n)-1 do
    InitItem(i);
  SetBrushColor(rgb(70,70,70));
  x:=WIDTH-HEIGHT div 2-200;
  y:=30;
  FillRect(x,y,x+400,y+200);
  SetFontColor(rgb(251, 201, 73));
  TextOut(x+15,y+20,'Статистка: ');
  SetFontSize(12);
  var d:=max(max(length(score.ToString),length(steps.ToString)),length(round(score/last_record*100).ToString+'%'))*15;
  SetFontColor(rgb(230,230,230)); TextOut(x+15,y+75,'Набрано очков: ');
  if score>=last_record then begin
    SetFontColor(rgb(94, 245, 44));
    TextOut(x+15,y+110,'Рекорд побит: ');
    SetFontColor(rgb(230,230,230));
    status_img1.Draw(x+215,y+20);
    if (score-last_record)/last_record>=0.5 
      then DrawInfoRect(x+180,y+108,d,12,round((score-last_record)/last_record*100).ToString+'%',clBlack,rgb(73, 252, 247))
      else DrawInfoRect(x+180,y+108,d,12,round((score-last_record)/last_record*100).ToString+'%',clBlack,rgb(73, 252, 91));
  end else begin 
  SetBrushColor(rgb(70,70,70)); SetFontColor(rgb(230,230,230)); TextOut(x+15,y+110,'Рекорд на: ');
    if score/last_record>=0.67 then begin
       status_img2.Draw(x+215,y+20);
       DrawInfoRect(x+180,y+108,d,12,round(score/last_record*100).ToString+'%',clBlack,rgb(158, 247, 129));
    end
    else if (score/last_record>=0.33)and(score/last_record<0.67) 
      then begin 
        status_img3.Draw(x+215,y+20);
        DrawInfoRect(x+180,y+108,d,12,round(score/last_record*100).ToString+'%',clBlack,rgb(213, 240, 237));
      end
      else begin
        status_img4.Draw(x+215,y+20);
        DrawInfoRect(x+180,y+108,d,12,round(score/last_record*100).ToString+'%',clBlack,rgb(252, 97, 73));
      end;
  end;
  SetBrushColor(rgb(70,70,70)); SetFontColor(rgb(230,230,230)); TextOut(x+15,y+145,'Фишек использовано: ');
  //DrawRectangle(x+215,y+20,x+395,y+195);
  DrawInfoRect(x+180,y+143,d,12,steps.ToString,clBlack,clWhite);
  DrawInfoRect(x+180,y+73,d,12,score.ToString,clBlack,clWhite);
  song.SoundLocation:='sounds/'+ends[random(1,6)];
  song.Play;
  if score > last_record 
    then last_record:= score;
  CreateDialog('Окончание игры','Все поля игры заняты!','Новая игра','Спасибо, я пошёл',3);
end;
procedure CreateBalls();
var r,i,k,c:integer; test:Tballs;
begin
  test:=[];
  if points > 0 then begin
    for i:=1 to COLOR_COUNT do
      test+=balls[i];
    for k:=1 to NEW_BALLS do begin
    // Рисуем старый шар
      if next[k,1] in test then
        next[k]:=GetRandomBall();
      if next[k,1]=-1 then begin
        GiveUp;
        exit;
      end;
      include(balls[next[k,2]],next[k,1]);
      include(test,next[k,1]);
    // Создаём новый шар
      c:=next[k,1];
      next[k]:=GetRandomBall;
      if next[k,1]=-1 then begin
        GiveUp;
        exit;
      end;
      InitItem(next[k,1]);
      InitItem(c);
      CheckItem(c);
    end;
  end;
end;
procedure DrawTable();
var i,j:integer;
begin
  bar_top:=10;
  bar_width:=WIDTH-HEIGHT+bar_top;
  item_size:=(HEIGHT-2*bar_top)div n;
  ball_size:=(item_size*2)div 3;
  for i:=1 to COLOR_COUNT do
    balls[i]:=[];
 for i:=1 to NEW_BALLS do
    for j:=1 to 2 do
      next[i,j]:=-1;
// Отрисовка
  SetBrushColor(rgb(105,105,105));
  FillRectangle(WIDTH-HEIGHT,1,WIDTH,HEIGHT);
  selected:=-1;
  SetPenColor(rgb(10,10,10));
  DrawRectangle(BAR_WIDTH-1,BAR_TOP-1,BAR_WIDTH+n*ITEM_SIZE+1,BAR_TOP+n*ITEM_SIZE+1);
  for i:=0 to sqr(n)-1 do
    InitItem(i);
end;
procedure ChangeValue();
var x,y,d:integer;
begin
  x:=BAR_WIDTH div 2;
  y:=BAR_TOP+100; d:=20;
  SetBrushColor(rgb(87,87,87));
  FillEllipse(x-BT_RADIUS-d,y-BT_RADIUS-d,x+BT_RADIUS+d,y+BT_RADIUS+d);
  d:=10; SetBrushColor(rgb(129,192,232));
  FillEllipse(x-BT_RADIUS-d,y-BT_RADIUS-d,x+BT_RADIUS+d,y+BT_RADIUS+d);
  SetFontSize(32);
  SetFontColor(rgb(42,63,76));
  if n>9 
  then TextOut(x-26,y-22,n)
  else TextOut(x-13,y-22,n)
end;
procedure LeftTabledDialog();
begin
  DrawButton(bar_width div 5,BAR_TOP+100,BT_RADIUS,-5,rgb(80,160,225));
  if n>1 then
    n:=n-1;
  if n=2 then begin
    b_lb:=2;
    DrawButton(bar_width div 5,BAR_TOP+100,BT_RADIUS,-5,rgb(80,80,80));
  end else begin
    DrawButton(bar_width div 5,BAR_TOP+100,BT_RADIUS,-5,rgb(80,160,225));
    b_lb:=1;
  end;
  DrawTable;
  ChangeValue;
end;
procedure RightTabledDialog();
begin
  DrawButton(bar_width-bar_width div 5,BAR_TOP+100,BT_RADIUS,5,rgb(80,160,225));
  n:=n+1;
  if n=3 then begin
    b_lb:=0;
    DrawButton(bar_width div 5,BAR_TOP+100,BT_RADIUS,-5,rgb(80,160,225));
  end;
  b_rb:=1;
  DrawTable;
  ChangeValue;
end;
procedure Restart();
begin
  LockDrawing;
// Появление таблицы
  ltcr:=230; dkcr:=220;
  DrawTable;
  SetBrushColor(rgb(105,105,105));
  FillRectangle(1,1,BAR_WIDTH-1,HEIGHT);
// Кнопочки
  b_p:=0;
  b_rb:=0;
  b_lb:=0;
  steps:=0;
  isbig:=false;
  DrawButton(bar_width div 2,BAR_TOP+190+BT_RADIUS,BT_RADIUS+10,10,rgb(57, 206, 70));
  DrawButton(bar_width div 5,BAR_TOP+100,BT_RADIUS,-5,rgb(91,172,234));
  DrawButton(bar_width-bar_width div 5,BAR_TOP+100,BT_RADIUS,5,rgb(91,172,234));
  ChangeValue;
  DrawButton(bar_width div 2,BAR_TOP+190+BT_RADIUS,BT_RADIUS+10,10,rgb(57, 206, 70));
  Redraw;
end;
procedure MouseDown(x1,y1,mb: integer);
var i,j,d,x,y,t,k:integer; ball,obl:Color;
const l = 0.9;
const grade=2;
begin
  if not time.Enabled then LockDrawing;
  if (x1>BAR_WIDTH+BAR_TOP)and(y1>BAR_TOP)and(x1<WIDTH-BAR_TOP)and(y1<HEIGHT-BAR_TOP)and(isgame=1) then begin
    j:=(x1-BAR_WIDTH) div ITEM_SIZE;
    i:=(y1-BAR_TOP) div ITEM_SIZE;
    ball:=findcolor(i*n+j);
    t:=selected;
    if mb=1 then
      if ballexists then begin
        selected:=i*n+j;
        if t>-1 then
          InitItem(t);
        Redraw;
        InitItem(selected);
      end
      else if (t>-1) and (CanMoveTo(j, i)) then begin
      // Перемещение шара
      obl:=findcolor(t);
      for k:=1 to COLOR_COUNT do
        if obl=colors[k] then begin
          exclude(balls[k],t);
          include(balls[k],i*n+j);
        end;
      
      for d := 1 to grade do begin
        SetBrushColor(rgb(round(ltcr*l),round(ltcr*l),round(ltcr*l)));
        y:=BAR_TOP+(t div n)*ITEM_SIZE + (ITEM_SIZE div 2);
        x:=BAR_WIDTH+(t mod n)*ITEM_SIZE + (ITEM_SIZE div 2);
        {FillPie(x, y, 27, (360 div grade) * (d-1)-1, (360 div grade) * d);}
        if d = grade
        then begin
          selected:=i*n+j;
          InitItem(t);
          InitItem(selected);
          pop.Play;
          ChangeSingle();
        end;
        Redraw;
        {sleep(3);}
      end;
  // Проверка линий
      if (not CheckItem(selected)) or (points=sqr(n)) then
        CreateBalls;
    end;
  end
  else if (sqr(x1-bar_width div 5)+sqr(y1-BAR_TOP-100)<=sqr(BT_RADIUS))and(b_lb<>2) then begin
    if isgame=0 then
      LeftTabledDialog()
    else if isgame=1 then CreateDialog('Изменить размер поля?','Игра не окончена. Покинуть игру?','ОК','Отмена',1);
  end else if (sqr(x1-bar_width+bar_width div 5)+sqr(y1-BAR_TOP-100)<=sqr(BT_RADIUS))and(b_rb<>2) then begin
        if isgame=0 then
      RightTabledDialog()
    else if isgame=1 then CreateDialog('Изменить размер поля?','Игра не окончена. Покинуть игру?','ОК','Отмена',2);
  end else if (sqr(x1-bar_width div 2)+sqr(y1-BAR_TOP-190-BT_RADIUS)<=sqr(BT_RADIUS+10))and(b_p<>2) then begin
    DrawButton(bar_width div 2,BAR_TOP+190+BT_RADIUS,BT_RADIUS+10,11,rgb(62, 224, 76));
    b_p:=1;
  end else if (isgame=2)and(x1>=btd1[1])and(y1>=btd1[2])and(x1<=btd1[3])and(y1<=btd1[4])and(d_b1=0) then begin
    d_b1:=1;
    FloodFill(btd1[1]+6,btd1[2]+6,rgb(80,160,225));
  end else if (isgame=2)and(x1>=btd2[1])and(y1>=btd2[2])and(x1<=btd2[3])and(y1<=btd2[4])and(d_b2=0) then begin
    d_b2:=1;
    FloodFill(btd2[1]+6,btd2[2]+6,rgb(80,160,225));
  end;
  if not time.Enabled then Redraw;
end;
procedure MouseUp(x1,y1,mb: integer);
begin
  if not time.Enabled then LockDrawing;
  if b_lb=1 then begin
    DrawButton(bar_width div 5,BAR_TOP+100,BT_RADIUS,-5,rgb(91,172,234));
    b_lb:=0;
  end else if b_rb=1 then begin
    DrawButton(bar_width-bar_width div 5,BAR_TOP+100,BT_RADIUS,5,rgb(91,172,234));
    b_rb:=0;
  end else if (b_p=1)and(isgame=0) then begin
    DrawButton(bar_width div 2,BAR_TOP+190+BT_RADIUS,BT_RADIUS+10,10,rgb(57, 206, 70));
    b_p:=0;
    if (sqr(x1-bar_width div 2)+sqr(y1-BAR_TOP-190-BT_RADIUS)<=sqr(BT_RADIUS+10))and(isgame=0) then begin
  // Начало игры
      SetBrushColor(rgb(105,105,105));
      FillRect(bar_width div 2-BT_RADIUS-12,BAR_TOP+178,bar_width div 2+BT_RADIUS+12,BAR_TOP+204+2*BT_RADIUS);
      song.SoundLocation:='sounds/'+starts[random(1,4)];
      song.Play;
      points:=sqr(n);
      isgame:=1;
      b_p:=2; score:=0;
      // 3 мяча
      for var i:=1 to NEW_BALLS do
        next[i]:=GetRandomBall;
      CreateBalls;
      // Игровые панельки
      ChangeSingle;
    end;
  end else if (isgame=2)and(d_b1=1) then begin
    d_b1:=0;
    isgame:=0;
    FloodFill(btd1[1]+6,btd1[2]+6,rgb(91,172,234));
    if (x1>=btd1[1])and(y1>=btd1[2])and(x1<=btd1[3])and(y1<=btd1[4]) then begin
      if dialogType=1 then LeftTabledDialog()
      else if dialogType=2 then RightTabledDialog();
      Restart;
    end;
  end else if (isgame=2)and(d_b2=1) then begin
    d_b2:=0;
    isgame:=1;
    FloodFill(btd1[1]+6,btd1[2]+6,rgb(91,172,234));
    if dialogType=3 then halt;
    for var i:=1 to sqr(n)-1 do
      InitItem(i);
  end;
  if not time.Enabled then Redraw;
end;
procedure TimerMain();
var x,y,bl:integer; was:boolean;
begin
  LockDrawing;
  foreach bl in phantoms do begin
    was:=true;
    InitItem(bl);
    if sizes[bl]>0 then begin
    sizes[bl]:=sizes[bl]-10;
    y:=BAR_TOP+(bl div n)*ITEM_SIZE+(ITEM_SIZE div 2);
    x:=BAR_WIDTH+(bl mod n)*ITEM_SIZE+(ITEM_SIZE div 2);
    DrawButton(x,y,sizes[bl],0,colors[dead[bl]]);
    end else exclude(phantoms,bl);
  end;
  Redraw;
  if not was then
    time.Stop;
  var z:=0;
end;
begin
  SetWindowCaption('Нажимайте на шарики');
  OnMouseDown:=MouseDown;
  OnMouseUp:=MouseUp;
  Window.Width:=WIDTH;
  Window.Height:=HEIGHT;
  ltcr:=230; dkcr:=220;
// Установка рекорда
  LAST_RECORD:=30;
// Звуковое оформление
  pop:=new system.Media.SoundPlayer;
  pop.SoundLocation:='sounds/pop.WAV';
  boom:=new system.Media.SoundPlayer;
  boom.SoundLocation:='sounds/boom.WAV';
  {torecord:=new system.Media.SoundPlayer;
  torecord.SoundLocation:='sounds/torecord.WAV';}
  song:=new system.Media.SoundPlayer;
  status_img1:= Picture.Create('images/allcorrect.png');
  status_img2:= Picture.Create('images/oncorrect.png');
  status_img3:= Picture.Create('images/fewcorrect.png');
  status_img4:= Picture.Create('images/nocorrect.png');
  n:=9;
  b_bk:=2;
  time:=new Timer(10,TimerMain);
  Restart;
end.