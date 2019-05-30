program space_invaders;
uses
    Sysutils,
    crt,
    zgl_main,
    zgl_screen,
    zgl_window,
    zgl_timers,
    zgl_file,
    zgl_memory,
    zgl_resources,
    zgl_font,
    zgl_textures,
    zgl_textures_jpg,
    zgl_textures_png,
    zgl_sound,
    zgl_sound_wav,
    zgl_primitives_2d,
    zgl_text,
    zgl_sprite_2d,
    zgl_utils,
    zgl_keyboard,
    zgl_mouse;
type
    ekran = (menu, poziom1, poziom2);
    ship_dane = record
      x, y, oslona : Integer;
      alive : Boolean;
    end;
    bullet_dane = record
      x, y : Integer;
      alive : Boolean;
    end;
    monster_dane = record
      x, y, xb, yb, v1, v2 : Integer;
      tex : zglPTexture;
      alive, bullet_alive : Boolean;
    end;
const
    //wymiary potworow i statku
    SZ_M1=40;
    W_M1=30;
    SZ_S1=60;
    W_S1=50;
    //wspolczynnik szybkosci pociskow wroga
    k = 20;
    //wymiary przyciskow
    XSI=200;
    YSI=60;
    XP=300;
    YP1=300;
    YP2=400;
    YW=500;
    SZ_SI=400;
    W_SI=180;
    SZ_P=200;
    W_P=50;

var
   fntMain : zglPFont;
   tlo_poziom1,tlo_poziom2,tlo_menu,space_invaders,tex_poziom1,tex_poziom2,wyjscie,tex_ship1,tex_monster1,tex_monster2,tex_monster3,tex_monster4,tex_temp : zglPTexture;
   ship1 : ship_dane;
   tex_bullet1,tex_bullet2 : zglPTexture;
   bullets : array [1..80] of bullet_dane;
   monsters : array [1..10, 1..5] of monster_dane;     //  10 kolumn  x  5 wierszy
   koniec,przegrana,esc_menu,nizej,prawo,lewo,war_temp : Boolean;
   aktualny_ekran : ekran;
   mouseEndX,mouseEndY,lwygranych,lprzegranych,plusLW,minusLP,szybkosc : Integer;
   shot,music : zglPSound;
   lw,lp : Text;
   s : string;

//prototypy
 procedure init_rozgrywka; forward;
 procedure init_menu; forward;
 procedure init_poziom1; forward;
 procedure init_poziom2; forward;
// INIT   INIT   INIT   INIT   INIT   INIT   INIT   INIT   INIT
procedure Init;
begin
   // czcinki
   fntMain:=font_LoadFromFile( 'dane/font.zfi' );
   Snd_Init;
   aktualny_ekran:=menu;
   esc_menu:=false;
   music := Snd_LoadFromFile ('dane/music.mp3',2);
   shot := Snd_LoadFromFile ('dane/shoot.wav',2);
   init_menu();
end;
// DRAW   DRAW   DRAW   DRAW   DRAW   DRAW   DRAW   DRAW   DRAW
procedure Draw;
var
 i,j : Integer;
 os : String;
begin
  if(aktualny_ekran=poziom1) Then begin
      //wyswietlenie tla
      ssprite2d_Draw(tlo_poziom1, 0, 0, 800, 600, 0  );
      //wyswietlanie statku jesli nie zostal zniszczony
      if (ship1.alive) Then ssprite2d_Draw(tex_ship1, ship1.x, ship1.y, SZ_S1, W_S1, 0 );
      //wyswietlanie pociskow gracza
      for i:=1 to 80 do if bullets[i].alive then ssprite2d_Draw(tex_bullet1, bullets[i].x, bullets[i].y, 18, 6, -90 );
      //wyswietlanie pociskow przeciwnikow
      for i:=1 to 10 do begin
       for j:=1 to 5 do begin
        if (monsters[i][j].bullet_alive) then ssprite2d_Draw(tex_bullet2, monsters[i][j].xb-2, monsters[i][j].yb-2, 7, 7, 0 );
       end;
      end;
      //wyswietlanie przeciwnikow
      for i:=1 to 10 do begin
         for j:=1 to 5 do begin
            if monsters[i][j].alive then ssprite2d_Draw(monsters[i][j].tex, monsters[i][j].x, monsters[i][j].y, SZ_M1, W_M1, 0 );
         end;
      end;
      //wyswietlanie napisow
      //text_Draw( fntMain, 10, 5,  'FPS: ' + u_IntToStr( zgl_Get( RENDER_FPS ) ) );
      text_Draw( fntMain, 10, 10, 'Poziom 1' );
      os:=IntToStr(ship1.oslona);
      text_Draw( fntMain, 200, 10, 'Stan oslony: ' + os );
      if (przegrana) Then text_Draw( fntMain, 250, 500, 'Przegrales :D  < Enter >' );;
      if (koniec = true) Then text_Draw( fntMain, 250, 500, 'Brawo! Tym razem Ci sie udalo.  < Enter >' );
   end;
   if(aktualny_ekran=poziom2) Then begin
       //wyswietlenie tla
       ssprite2d_Draw(tlo_poziom2, 0, 0, 800, 600, 0  );
       //wyswietlanie statku jesli nie zostal zniszczony
       if (ship1.alive) Then ssprite2d_Draw(tex_ship1, ship1.x, ship1.y, SZ_S1, W_S1, 0 );
       //wyswietlanie pociskow gracza
       for i:=1 to 80 do if bullets[i].alive then ssprite2d_Draw(tex_bullet1, bullets[i].x, bullets[i].y, 18, 6, -90 );
       //wyswietlanie pociskow przeciwnikow
       for i:=1 to 10 do begin
        for j:=1 to 5 do begin
         if (monsters[i][j].bullet_alive) then ssprite2d_Draw(tex_bullet2, monsters[i][j].xb-2, monsters[i][j].yb-2, 7, 7, 0 );
        end;
       end;
       //wyswietlanie przeciwnikow
       for i:=1 to 10 do begin
          for j:=1 to 5 do begin
             if monsters[i][j].alive then ssprite2d_Draw(monsters[i][j].tex, monsters[i][j].x, monsters[i][j].y, SZ_M1, W_M1, 0 );
          end;
       end;
       //wyswietlanie napisow
       //text_Draw( fntMain, 10, 5,  'FPS: ' + u_IntToStr( zgl_Get( RENDER_FPS ) ) );
       text_Draw( fntMain, 10, 10, 'Poziom 2' );
       os:=IntToStr(ship1.oslona);
       text_Draw( fntMain, 200, 10, 'Stan oslony: ' + os );
       if (przegrana) Then text_Draw( fntMain, 250, 500, 'Przegrales :D  < Enter >' );;
       if (koniec = true) Then text_Draw( fntMain, 250, 500, 'Brawo! Tym razem Ci sie udalo.  < Enter >' );
   end;
 if(aktualny_ekran=menu) Then begin
     ssprite2d_Draw(tlo_menu, 0, 0, 800, 600, 0  );
     ssprite2d_Draw(space_invaders, XSI, YSI, SZ_SI, W_SI, 0  );
     ssprite2d_Draw(tex_poziom1, XP, YP1, SZ_P, W_P, 0  );
     ssprite2d_Draw(tex_poziom2, XP, YP2, SZ_P, W_P, 0  );
     ssprite2d_Draw(wyjscie, XP, YW, SZ_P, W_P, 0  );
     text_Draw( fntMain, 550, 480, 'Liczba wygranych gier: ' + IntToStr(lwygranych) );
     text_Draw( fntMain, 550, 505, 'Liczba przegranych gier: ' + IntToStr(lprzegranych) );
     text_Draw( fntMain, 638, 580, 'Autor: Dominik Bazan' );
     //text_Draw( fntMain, 10, 5,  'FPS: ' + u_IntToStr( zgl_Get( RENDER_FPS ) ) );
     //text_Draw( fntMain, 10, 25, 'Main menu: 1 - poziom pierwszy Esc - wyjscie z gry 0-main menu' );

 end;
 if(esc_menu=true) Then text_Draw( fntMain, 300, 500, 'Czy na pewno chcesz wyjsc z gry? t/n' );
 if(esc_menu=true) Then text_Draw( fntMain, 300, 517, 'By wyjsc do menu wcisnij 0' );
end;
// UPDATE   UPDATE   UPDATE   UPDATE   UPDATE   UPDATE   UPDATE
procedure Update();
var i,j : Integer;
begin
 //wczytanie liczby wygranych oraz przegranych gier z plikow, modyfikacja i zapis
 // +1
 Assign(lw,'dane/lw.txt');
 Reset(lw);
 ReadLN(lw,s);
 lwygranych:=StrToInt(s);
 lwygranych:=lwygranych+plusLW;
 plusLW:=0;
 s:=IntToStr(lwygranych);
 Rewrite(lw);
 Write(lw,s);
 Close(lw);
 // -1
 Assign(lp,'dane/lp.txt');
 Reset(lp);
 ReadLN(lp,s);
 lprzegranych:=StrToInt(s);
 lprzegranych:=lprzegranych+minusLP;
 minusLP:=0;
 s:=IntToStr(lprzegranych);
 Rewrite(lp);
 Write(lp,s);
 Close(lp);

 //wyjscie z gry
 if (esc_menu=true) AND (key_PRESS( K_T ) OR (key_PRESS( K_ENTER ))) Then zgl_Exit()
 else if (esc_menu=true) AND (key_PRESS( K_N )) Then esc_menu:=NOT(esc_menu);
 //zmiana stanu esc_menu
 if key_PRESS( K_ESCAPE ) Then esc_menu:=NOT(esc_menu);
 //wyjscie do menu
 if key_PRESS( K_0 ) Then begin
     aktualny_ekran:=menu;
     init_menu();
 end;
 //rozpoczecie poziomu pierwszego
 if key_PRESS( K_1 ) Then begin
     aktualny_ekran:=poziom1;
     init_poziom1();
 end;
 //rozpoczecie poziomu drugiego
 if key_PRESS( K_2 ) Then begin
     aktualny_ekran:=poziom2;
     init_poziom2();
 end;
 //przejscie do menu po wygranym poziomie
 if (koniec = true) AND (key_PRESS( K_ENTER )) Then begin
     koniec:=false;
     aktualny_ekran:=menu;
     plusLW:=1;
 end;
 //zniszczenie wszystkich przeciwnikow (hak)
 if key_PRESS( K_Y ) Then
   for i:=1 to 10 do
    for j:=1 to 5 do monsters[i][j].alive:=false;
 //czy statek gracza zniszczony
 if ship1.oslona <= 0 Then przegrana := true;
 if NOT(ship1.alive) Then ship1.oslona:=0;
 //gdy przegrana
 if przegrana Then begin
     if war_temp Then begin
      minusLP:=1;
      war_temp:=false;
     end;
     if key_PRESS ( K_ENTER ) Then aktualny_ekran:=menu;
     ship1.alive:=false;
 end;
 // klikanie opcji myszka
 if mouse_down(M_BLEFT) then
   begin
       mouseEndX:=mouse_x;
       mouseEndY:=mouse_y;
   end;
   if (NOT(mouse_down(M_BLEFT))) and (mouseEndX>XP) and (mouseEndX<XP+SZ_P) and (mouseEndY>YP1) and (mouseEndY<YP1+W_P) then
   begin
       mouseEndX:=0;
       mouseEndY:=0;
       aktualny_ekran:=poziom1;
       init_poziom1();
   end
   else if (NOT(mouse_down(M_BLEFT))) and (mouseEndX>XP) and (mouseEndX<XP+SZ_P) and (mouseEndY>YP2) and (mouseEndY<YP2+W_P) then
   begin
       mouseEndX:=0;
       mouseEndY:=0;
       aktualny_ekran:=poziom2;
       init_poziom2();
   end
   else if (NOT(mouse_down(M_BLEFT))) and (mouseEndX>XP) and (mouseEndX<XP+SZ_P) and (mouseEndY>YW) and (mouseEndY<YW+W_P) then
   begin
       mouseEndX:=0;
       mouseEndY:=0;
       zgl_Exit();
   end;

 key_ClearState();
end;
// TIMER_FIRE   TIMER_FIRE   TIMER_FIRE   TIMER_FIRE   TIMER_FIRE
procedure Timer_fire;
var i : Integer;
begin
     //strzelanie z 2 dzialek
     if (key_DOWN(K_SPACE)) AND (ship1.alive) Then begin
           for i:=1 to 40 do if bullets[i].alive=false then break;
           bullets[i].alive:=true;
           bullets[i].x:=ship1.x+2;
           bullets[i].y:=ship1.y+10;
           for i:=41 to 80 do if bullets[i].alive=false then break;
           bullets[i].alive:=true;
           bullets[i].x:=ship1.x+40;
           bullets[i].y:=ship1.y+10;
           snd_Play(shot);
     end;
end;
// TIMER_FIRE_MONSTERS   TIMER_FIRE_MONSTERS   TIMER_FIRE_MONSTERS
procedure Timer_fire_monsters;
var i,j,kolej_strzal1,kolej_strzal2 : Integer;
begin
     Randomize;
     kolej_strzal1:=random(10)+1;
     kolej_strzal2:=random(5)+1;
     //strzaly przeciwnikow
     for i := 1 to 10 do begin
        for j := 1 to 5 do begin
           if (i=kolej_strzal1) AND (j=kolej_strzal2) AND (monsters[i][j].bullet_alive=false) AND (monsters[i][j].alive=true) AND (ship1.alive) Then begin
              monsters[i][j].bullet_alive := true;
              monsters[i][j].yb := monsters[i][j].y;
              monsters[i][j].xb := monsters[i][j].x;
              monsters[i][j].v1 := ship1.x-monsters[i][j].xb;
              monsters[i][j].v2 := ship1.y-monsters[i][j].yb;
           end;
        end;
     end;
end;
// TIMER_BULLET   TIMER_BULLET   TIMER_BULLET   TIMER_BULLET
procedure Timer_bullet;
var i : Integer;
begin
    for i := 1 to 80 do if bullets[i].alive=true then begin
        bullets[i].y:=bullets[i].y-10;
        if (bullets[i].y<=-1) then bullets[i].alive:=false;
    end;
end;
// TIMER_BULLET_MONSTER   TIMER_BULLET_MONSTER   TIMER_BULLET_MONSTER
procedure Timer_bullet_monster;
var i,j : Integer;
begin
    //przesowanie pociskow i niszczenie jak wyleca za ekran
    for i := 1 to 10 do begin
     for j := 1 to 5 do begin
      if monsters[i][j].bullet_alive then begin
        monsters[i][j].xb := monsters[i][j].xb + (monsters[i][j].v1 div k);
        monsters[i][j].yb := monsters[i][j].yb + (monsters[i][j].v2 div k);
        if (monsters[i][j].yb>601) OR (monsters[i][j].xb>801) OR (monsters[i][j].xb<0)
           Then begin monsters[i][j].bullet_alive:=false; end;
        end;
     end;
    end;
end;
// Timer_monsters_moving   Timer_monsters_moving   Timer_monsters_moving
procedure Timer_monsters_moving;
var i,j : Integer;
begin
    if nizej=true Then begin
      for i := 1 to 10 do begin
       for j := 1 to 5 do begin
         monsters[i][j].y:=monsters[i][j].y+1;
         if monsters[i][j].y>320 Then nizej:=false;
       end;
      end;
    end;
end;
// TIMER_SHIP_MOVE   TIMER_SHIP_MOVE   TIMER_SHIP_MOVE
procedure Timer_ship_move;
begin
    if key_DOWN( K_LEFT ) Then if(ship1.x>0) THEN ship1.x:=ship1.x-10;
    if key_DOWN( K_RIGHT ) Then if(ship1.x<740) THEN ship1.x:=ship1.x+10;
    if key_DOWN( K_UP ) Then if(ship1.y>440) THEN ship1.y:=ship1.y-10;
    if key_DOWN( K_DOWN ) Then if(ship1.y<550) THEN ship1.y:=ship1.y+10;
    if key_DOWN( K_Z ) Then if(ship1.x>0) THEN ship1.x:=ship1.x-20;
    if key_DOWN( K_C ) Then if(ship1.x<740) THEN ship1.x:=ship1.x+20;

    //wnd_SetCaption('01-Initialization[ FPS: '+u_IntToStr(zgl_Get(RENDER_FPS))+' ]');
end;
// Timer_niszcz_blok   Timer_niszcz_blok   Timer_niszcz_blok   Timer_niszcz_blok
procedure Timer_niszcz_blok;
var i,j,k,losowa : Integer;
begin
    Randomize;
    for i:=1 to 10 do begin
     for j:=1 to 5 do begin
      for k:=1 to 80 do begin
       if (monsters[i][j].alive=true) and (bullets[k].alive=true) Then
        if (abs(bullets[k].x-(monsters[i][j].x+(SZ_M1/2)))<=20) AND (abs(bullets[k].y-(monsters[i][j].y+(W_M1/2)))<=15)
        then begin
            monsters[i][j].alive := false;
            bullets[k].alive := false;
            losowa:=random(40)+1;
            if losowa = i Then ship1.oslona:=ship1.oslona+1;
        end;
      end;
     end;
    end;
    //sprawdzanie czy wszyscy przyciwnicy pokonani
    koniec:=true;
    for i:=1 to 10 do begin
     for j:=1 to 5 do begin
      if monsters[i][j].alive = true Then begin
          koniec := false;
          break;
      end;
     end;
     if monsters[i][j].alive = true Then break;
    end;
end;
// Timer_niszcz_statku   Timer_niszcz_statku   Timer_niszcz_statku
procedure Timer_niszcz_statku;
var i,j : Integer;
begin
    for i:=1 to 10 do begin
     for j:=1 to 5 do begin
      if ((abs(monsters[i][j].xb-(ship1.x+(SZ_S1/2))))<=(SZ_S1/2)) AND ((abs(monsters[i][j].yb-(ship1.y+(W_S1/2))))<=(W_S1/2)) Then begin
            monsters[i][j].bullet_alive := false;
            ship1.oslona := ship1.oslona-1;
            monsters[i][j].xb := 0;
            monsters[i][j].yb := -100;
      end;
     end;
    end;
end;
//Timer_kierunek_monster   Timer_kierunek_monster   Timer_kierunek_monster
procedure Timer_kierunek_monster;
var i,j : Integer;
begin
  //poruszanie sie na boki
  for i:=1 to 10 do begin
    for j:=1 to 5 do begin
      if (monsters[i][j].alive) AND (monsters[i][j].x>750) Then begin
        prawo:=false;
        lewo:=true;
      end;
    end;
  end;

  for i:=1 to 10 do begin
    for j:=1 to 5 do begin
      if (monsters[i][j].alive) AND (monsters[i][j].x<10) Then begin
        prawo:=true;
        lewo:=false;
      end;
    end;
  end;

  if prawo Then begin
    for i:=1 to 10 do begin
     for j:=1 to 5 do begin
         monsters[i][j].x:=monsters[i][j].x+szybkosc;
     end;
    end;
  end
  else if lewo Then begin
    for i:=1 to 10 do begin
     for j:=1 to 5 do begin
         monsters[i][j].x:=monsters[i][j].x-szybkosc;
     end;
    end;
  end;
end;
// INT_MENU   INT_MENU   INT_MENU   INT_MENU   INT_MENU   INT_MENU   INT_MENU
procedure init_menu;
begin
    koniec := false;
    tlo_menu := tex_LoadFromFile( 'dane/tlo_menu.jpg' );
    space_invaders := tex_LoadFromFile( 'dane/space_invaders.png' );
    tex_poziom1 := tex_LoadFromFile( 'dane/poziom1.png' );
    tex_poziom2 := tex_LoadFromFile( 'dane/poziom2.png' );
    wyjscie := tex_LoadFromFile( 'dane/wyjscie.png' );
end;
// INT_POZIOM1   INT_POZIOM1   INT_POZIOM1   INT_POZIOM1   INT_POZIOM1
procedure init_poziom1;
var i,j,los : Integer;
begin
   Randomize;
   szybkosc:=2;
   ship1.oslona:=5;
   nizej:=true;
   init_rozgrywka();
   tlo_poziom1 := tex_LoadFromFile( 'dane/tlo_poziom1.jpg' );
   //okreslanie poczatkowej pozycji przeciwnikow i ich formy tekstur
   for i:=1 to 10 do begin
    for j:=1 to 5 do begin
     monsters[i][j].alive := true;
     monsters[i][j].bullet_alive := false;
     monsters[i][j].x := 75*i-40;
     monsters[i][j].y := 40*j-30;
     los:=random(3);
         CASE los OF
              0 : monsters[i][j].tex:=tex_monster1;
              1 : monsters[i][j].tex:=tex_monster2;
              2 : monsters[i][j].tex:=tex_monster3;
              3 : monsters[i][j].tex:=tex_monster4;
         END;
    end;
   end;
end;
// INT_POZIOM2   INT_POZIOM2   INT_POZIOM2   INT_POZIOM2   INT_POZIOM2
procedure init_poziom2;
var i,j,los : Integer;
begin
   Randomize;
   ship1.oslona:=2;
   szybkosc:=5;
   nizej:=true;
   init_rozgrywka();
   tlo_poziom2 := tex_LoadFromFile( 'dane/tlo_poziom2.jpg' );
   //okreslanie poczatkowej pozycji przeciwnikow i ich formy tekstur
   for i:=1 to 10 do begin
    for j:=1 to 5 do begin
     monsters[i][j].alive := true;
     monsters[i][j].bullet_alive := false;
     monsters[i][j].x := 75*i-40;
     monsters[i][j].y := 40*j-30;
     los:=random(3);
         CASE los OF
              0 : monsters[i][j].tex:=tex_monster1;
              1 : monsters[i][j].tex:=tex_monster2;
              2 : monsters[i][j].tex:=tex_monster3;
              3 : monsters[i][j].tex:=tex_monster4;
         END;
    end;
   end;
end;
// INIT_ROZGRYWKA   INIT_ROZGRYWKA   INIT_ROZGRYWKA   INIT_ROZGRYWKA
procedure init_rozgrywka;
begin
   //ladowanie tekstur potrzebnych do gry
   tex_monster1 := tex_LoadFromFile( 'dane/monster1.png' );
   tex_monster2 := tex_LoadFromFile( 'dane/monster2.png' );
   tex_monster3 := tex_LoadFromFile( 'dane/monster3.png' );
   tex_monster4 := tex_LoadFromFile( 'dane/monster4.png' );

   tex_ship1 := tex_LoadFromFile( 'dane/ship1.png' );

   tex_bullet1 := tex_LoadFromFile( 'dane/bullet1.png' );
   tex_bullet2 := tex_LoadFromFile( 'dane/bullet2.png' );

   //okreslanie poczatkowej pozycji statku i jego stanu
   war_temp:=true;
   przegrana := false;
   prawo:=true;
   koniec := false;
   ship1.alive := true;
   ship1.x := 400;
   ship1.y := 550;
end;
// MAIN   MAIN   MAIN   MAIN   MAIN   MAIN   MAIN   MAIN   MAIN   MAIN
BEGIN
 timer_Add( @Timer_ship_move, 20 );
 timer_Add( @Timer_fire, 300 );
 timer_Add( @Timer_bullet, 20 );
 timer_Add( @Timer_niszcz_blok, 20 );          //niszczenie przeciwnikow
 timer_Add( @Timer_niszcz_statku, 100 );
 timer_Add( @Timer_bullet_monster, 45 );       //przesowanie pociskow i niszczenie jak wyleca za ekran
 timer_Add( @Timer_fire_monsters, 500 );       //ktory strzela w jaka strone i cz w ogole
 timer_Add( @Timer_monsters_moving, 100 );
 timer_Add( @Timer_kierunek_monster, 30 );

 zgl_Reg( SYS_LOAD, @Init );
 zgl_Reg( SYS_DRAW, @Draw );
 zgl_Reg( SYS_UPDATE, @Update );

 // naglowek okna
 wnd_SetCaption( 'SPACE INVADERS by Dominik Bazan' );

 wnd_ShowCursor( TRUE );

 scr_SetOptions( 800, 600, REFRESH_MAXIMUM, FALSE, FALSE );

 zgl_Init();
END.
