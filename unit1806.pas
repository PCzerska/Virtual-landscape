unit unit1806;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  OpenGLContext, gl, glu, Lconvencoding,glext, LCLType;

type

  { TForm1 }

  TForm1 = class(TForm)
    OpenGLControl2: TOpenGLControl;
    Dodaj_tekstury: TButton;
    Usun_tekstury: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    OpenGLControl1: TOpenGLControl;
    Timer1: TTimer;
    procedure Dodaj_teksturyClick(Sender: TObject);
    procedure Usun_teksturyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure OpenGLControl1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OpenGLControl1Paint(Sender: TObject);
    procedure OpenGLControl1Resize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

  f3d=record x,y,z:single  end;

  const
  maks = 150;

  type
  TPoz = record
    x, y, z, k: Single;
    xw, yw, zw: Single;
  end;

var
  poz: TPoz;
  Form1: TForm1;
  k, k1: Single;
  xpoz,ypoz:integer;
  bmp1,bmp2,bmp3,bmp4, bmp5, bmp6, bmp7, bmp8:TBitmap;
  tex1,tex2,tex3,tex4, tex5, tex6, tex7, tex8:LongWord;
  teren: array of array of f3d;
  ter:array [-10..10,-10..10] of single;
  budynki:array of record x,y,z,s,obr:single end;
  tablos:array of record x,y,z,m, obr:single end;
  tablos2:array of record x,y,z,m, obr :single end;
  tablos3:array of record x,y,z,m, obr:single end;

implementation

{$R *.lfm}

{ TForm1 }

procedure JpgBmp(nazwa:String; var bmpt:TBitmap);
  var pic:TPicture;
begin
  pic:=TPicture.Create;
  try
    pic.LoadFromFile(nazwa);
    bmpt.PixelFormat:=pf24bit;
    bmpt.Width:=Pic.Graphic.Width;
    bmpt.Height:=Pic.Graphic.Height;
    bmpt.Canvas.Draw(0,0,Pic.Graphic);
  finally
    FreeAndNil(pic);
  end;
end;

function CreateTexture(Width,Height:Integer; pData:Pointer):GLUInt;
  var Texture:GLuint;
begin
  glEnable(GL_TEXTURE_2D);
  glGenTextures(1,@Texture);
  glBindTexture(GL_TEXTURE_2D,Texture);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
  glTexImage2D(GL_TEXTURE_2D,0,GL_RGB,Width,Height,0,GL_BGR_EXT,GL_UNSIGNED_BYTE,pData);
  Result:=Texture;
end;

procedure LoadTexture(NazPliku:string; var bmpt:TBitmap; var texture: GLuint);
  var st:string;
      pbuf:PInteger;
begin
  if bmpt<>nil then bmpt.Free;
  bmpt:=TBitmap.Create;
  st:=copy(NazPliku,Length(NazPliku)-2,3);
  if st='jpg' then JpgBmp(NazPliku,bmpt)
              else bmpt.LoadFromFile(NazPliku);
  pbuf:=PInteger(bmpt.RawImage.Data);
  texture:=CreateTexture(bmpt.Width,bmpt.Height,pbuf);
end;

procedure teren_wykonaj(nx,ny:integer; dz,ddx,ddy,ddz:single);
  var w,wsp,pozx,pozy:single;
        maksx,maksy,i,j,iwsp,iw,jw:integer;
        begin  SetLength(teren,ny,nx);
        maksx:=nx-1; maksy:=ny-1;  wsp:=5; iwsp:=trunc(wsp);
        for i:=Low(teren) to High(teren)-1 do
        begin
          for j:=Low(teren[i]) to High(teren[i])-1 do
          begin
            w:=random*ddz;
            pozx:=(i-maksx/2);
            pozy:=(j-maksy/2);
            teren[i][j].x:=pozx;
            teren[i][j].y:=pozy;
            teren[i][j].z:=sin(i/15+1)*cos(j/11)*dz+w;
          end;
        end;
        end;


function il_wek(vc,vl,vp:f3d):f3d;
  var w,a,b:f3d;
begin
  a.x:=vl.x-vc.x; a.y:=vl.y-vc.y; a.z:=vl.z-vc.z;
  b.x:=vp.x-vc.x; b.y:=vp.y-vc.y; b.z:=vp.z-vc.z;
  w.x:=a.y*b.z-a.z*b.y;
  w.y:=a.z*b.x-a.x*b.z;
  w.z:=a.x*b.y-a.y*b.x;
  il_wek:=w;
end;

function norm_wek(w:f3d):f3d;
  var d:double;
begin
  d:=sqrt(sqr(w.x)+sqr(w.y)+sqr(w.z));
  if d>0 then begin result.x:=w.x/d; result.y:=w.y/d; result.z:=w.z/d end
         else begin result.x:=0; result.y:=0; result.z:=0
end;
end;

procedure teren_rysuj;
  var i,j:integer;vn:f3d;
  begin  for i:=Low(teren) to High(teren)-3 do
  begin
    if glIsTexture(tex5)=GL_TRUE then glBindTexture(GL_TEXTURE_2D, Tex5);
    glBegin(GL_TRIANGLE_STRIP);
    for j:=Low(teren[i]) to High(teren[i])-3 do
    begin
      vn:=il_wek(teren[i][j],teren[i][j+1],teren[i+1][j]);
      glNormal3fv(@vn);
      glTexCoord2f(0,0);
      glVertex3f(teren[i][j].x,teren[i][j].y,teren[i][j].z);
      vn:=il_wek(teren[i+1][j],teren[i+1][j+1],teren[i+2][j]);
      glNormal3fv(@vn);
      glTexCoord2f(0,0);
      glVertex3f(teren[i+1][j].x,teren[i+1][j].y,teren[i+1][j].z);
    end;
    glEnd;
  end;
  end;

procedure oswietlenie;
  const
      AmbientLight: array[0..3] of GLfloat = (0.3,0.3,0.3,1);
      DiffuseLight: array[0..3] of GLfloat = (0.8,0.8,0.8,1);
      SpecularLight: array[0..3] of GLfloat = (0.9,0.9,0.9,1);
      specReflection: array[0..3] of GLfloat = (0.9,0.9,0.9,1);
      positionLight: array[0..3] of GLfloat = (15, 10, -1, -1);
      spotdirectionLight: array[0..3] of GLfloat = (0,0,1,1.0);
begin
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glLightfv(GL_LIGHT0,GL_AMBIENT,ambientLight);
  glLightfv(GL_LIGHT0,GL_DIFFUSE,diffuseLight);
  glLightfv(GL_LIGHT0,GL_SPECULAR,specularLight);
  glLightfv(GL_LIGHT0,GL_POSITION,positionLight);
  glLightfv(GL_LIGHT0,GL_SPOT_DIRECTION,spotdirectionLight);
  glLightf(GL_LIGHT0,GL_SPOT_EXPONENT,10);
  glLightf(GL_LIGHT0,GL_SPOT_CUTOFF,180);

  glMaterialfv(GL_FRONT,GL_AMBIENT_AND_DIFFUSE,@DiffuseLight)
end;


function normalna(xc,yc,zc,xl,yl,zl,xp,yp,zp:single):f3d;
  var c,l,p,n:f3d;
begin
  with c do begin x:=xc; y:=yc; z:=zc; end;
  with l do begin x:=xl; y:=yl; z:=zl; end;
  with p do begin x:=xp; y:=yp; z:=zp; end;
  n:=il_wek(c,l,p);
  normalna:=norm_wek(n);
end;

procedure slup;
  var p:array [0..3] of f3d;
      norm,n:f3d;
begin
  with p[0] do begin x:=0.1; y:=0.1; z:=0 end;
  with p[1] do begin x:=-0.1; y:=0; z:=0 end;
  with p[2] do begin x:=0; y:=-0.1; z:=0 end;
  with p[3] do begin x:=0; y:=0; z:=1 end;

  glBindTexture(GL_TEXTURE_2D,tex4);
  glBegin(GL_TRIANGLES);
    norm:=il_wek(p[0],p[1],p[3]);
    n:=norm_wek(norm);
    glNormal3fv(@n);
    glTexCoord2f(0,0);
    glVertex3fv(@p[0]);
    glTexCoord2f(1,0);
    glVertex3fv(@p[1]);
    glTexCoord2f(0.5,1);
    glVertex3fv(@p[3]);

    norm:=il_wek(p[1],p[2],p[3]);
    n:=norm_wek(norm);
    glNormal3fv(@n);
    glTexCoord2f(0,0);
    glVertex3fv(@p[1]);
    glTexCoord2f(1,0);
    glVertex3fv(@p[2]);
    glTexCoord2f(0.5,1);
    glVertex3fv(@p[3]);

    norm:=il_wek(p[2],p[0],p[3]);
    n:=norm_wek(norm);
    glNormal3fv(@n);
    glTexCoord2f(0,0);
    glVertex3fv(@p[2]);
    glTexCoord2f(1,0);
    glVertex3fv(@p[0]);
    glTexCoord2f(0.5,1);
    glVertex3fv(@p[3]);
  glEnd;
end;

procedure narysuj_szescian;
begin

  glBindTexture(GL_TEXTURE_2D,tex4);
  glBegin(GL_QUADS);

    // Górna ściana
    glTexCoord2f(0, 1);
    glVertex3f(-0.1, 0.1, 1.3);
    glTexCoord2f(1, 1);
    glVertex3f(0.1, 0.1, 1.3);
    glTexCoord2f(1, 0);
    glVertex3f(0.1, -0.1, 1.3);
    glTexCoord2f(0, 0);
    glVertex3f(-0.1, -0.1, 1.3);

    // Dolna ściana
    glTexCoord2f(0, 1);
    glVertex3f(-0.1, 0.1, 1.0);
    glTexCoord2f(1, 1);
    glVertex3f(0.1, 0.1, 1.0);
    glTexCoord2f(1, 0);
    glVertex3f(0.1, -0.1, 1.0);
    glTexCoord2f(0, 0);
    glVertex3f(-0.1, -0.1, 1.0);

    // Lewa ściana
    glTexCoord2f(0, 1);
    glVertex3f(-0.1, 0.1, 1.3);
    glTexCoord2f(1, 1);
    glVertex3f(-0.1, 0.1, 1.0);
    glTexCoord2f(1, 0);
    glVertex3f(-0.1, -0.1, 1.0);
    glTexCoord2f(0, 0);
    glVertex3f(-0.1, -0.1, 1.3);

    // Prawa ściana
    glTexCoord2f(0, 1);
    glVertex3f(0.1, 0.1, 1.3);
    glTexCoord2f(1, 1);
    glVertex3f(0.1, 0.1, 1.0);
    glTexCoord2f(1, 0);
    glVertex3f(0.1, -0.1, 1.0);
    glTexCoord2f(0, 0);
    glVertex3f(0.1, -0.1, 1.3);

    // Przednia ściana
    glTexCoord2f(0, 1);
    glVertex3f(-0.1, 0.1, 1.3);
    glTexCoord2f(1, 1);
    glVertex3f(0.1, 0.1, 1.3);
    glTexCoord2f(1, 0);
    glVertex3f(0.1, 0.1, 1.0);
    glTexCoord2f(0, 0);
    glVertex3f(-0.1, 0.1, 1.0);

    // Tylna ściana
    glTexCoord2f(0, 1);
    glVertex3f(-0.1, -0.1, 1.3);
    glTexCoord2f(1, 1);
    glVertex3f(0.1, -0.1, 1.3);
    glTexCoord2f(1, 0);
    glVertex3f(0.1, -0.1, 1.0);
    glTexCoord2f(0, 0);
    glVertex3f(-0.1, -0.1, 1.0);
  glEnd;
end;



procedure narysuj_szescian2;
begin


  glBegin(GL_QUADS);
    // Górna ściana
    glVertex3f(-0.025, 0.2, 1.2);
    glVertex3f(0.025, 0.2, 1.2);
    glVertex3f(0.025, 0.2, 1.1);
    glVertex3f(-0.025, 0.2, 1.1);

    // Dolna ściana
    glVertex3f(-0.025, 0.1, 1.2);
    glVertex3f(0.025, 0.1, 1.2);
    glVertex3f(0.025, 0.1, 1.1);
    glVertex3f(-0.025, 0.1, 1.2);

    // Lewa ściana
    glVertex3f(-0.025, 0.2, 1.2);
    glVertex3f(-0.025, 0.2, 1.1);
    glVertex3f(-0.025, 0.1, 1.1);
    glVertex3f(-0.025, 0.1, 1.2);

    // Prawa ściana
    glVertex3f(0.025, 0.2, 1.2);
    glVertex3f(0.025, 0.2, 1.1);
    glVertex3f(0.025, 0.1, 1.1);
    glVertex3f(0.025, 0.1, 1.2);

    // Przednia ściana
    glVertex3f(-0.025, 0.2, 1.2);
    glVertex3f(0.025, 0.2, 1.2);
    glVertex3f(0.025, 0.1, 1.2);
    glVertex3f(-0.025, 0.1, 1.2);

    // Tylna ściana
    glVertex3f(-0.025, 0.1, 1.1);
    glVertex3f(0.025, 0.1, 1.1);
    glVertex3f(0.025, 0.1, 1.1);
    glVertex3f(-0.025, 0.1, 1.1);

    // Śmiglo 1
    glVertex3f(0.025, 0.14, 1.14);
    glVertex3f(0.3, 0.16, 1.14);
    glVertex3f(0.3, 0.14, 1.14);
    glVertex3f(0.025, 0.16, 1.14);

    // Lewa ściana

    glVertex3f(0.025, 0.14, 1.14);
    glVertex3f(0.025, 0.14, 1.16);
    glVertex3f(0.025, 0.16, 1.16);
    glVertex3f(0.025, 0.16, 1.14);

    // Prawa ściana
    glVertex3f(0.3, 0.14, 1.14);
    glVertex3f(0.3, 0.14, 1.16);
    glVertex3f(0.3, 0.16, 1.16);
    glVertex3f(0.3, 0.16, 1.14);

    // Przednia ściana
    glVertex3f(0.025, 0.14, 1.14);
    glVertex3f(0.3, 0.14, 1.14);
    glVertex3f(0.3, 0.14, 1.16);
    glVertex3f(0.025, 0.14, 1.16);

    // Tylna ściana
    glVertex3f(0.025, 0.16, 1.14);
    glVertex3f(0.3, 0.16, 1.14);
    glVertex3f(0.3, 0.16, 1.16);
    glVertex3f(0.025, 0.16, 1.16);

    // Śmiglo 2
    glVertex3f(-0.025, 0.14, 1.14);
    glVertex3f(-0.3, 0.16, 1.14);
    glVertex3f(-0.3, 0.14, 1.14);
    glVertex3f(-0.025, 0.16, 1.14);

    // Lewa ściana
    glVertex3f(-0.025, 0.14, 1.14);
    glVertex3f(-0.025, 0.14, 1.16);
    glVertex3f(-0.025, 0.16, 1.16);
    glVertex3f(-0.025, 0.16, 1.14);

    // Prawa ściana
    glVertex3f(-0.3, 0.14, 1.14);
    glVertex3f(-0.3, 0.14, 1.16);
    glVertex3f(-0.3, 0.16, 1.16);
    glVertex3f(-0.3, 0.16, 1.14);

    // Przednia ściana
    glVertex3f(-0.025, 0.14, 1.14);
    glVertex3f(-0.3, 0.14, 1.14);
    glVertex3f(-0.3, 0.14, 1.16);
    glVertex3f(-0.025, 0.14, 1.16);

    // Tylna ściana
    glVertex3f(-0.025, 0.16, 1.14);
    glVertex3f(-0.3, 0.16, 1.14);
    glVertex3f(-0.3, 0.16, 1.16);
    glVertex3f(-0.025, 0.16, 1.16);

    // Śmiglo 3
    glVertex3f(-0.01, 0.14, 1.2);
    glVertex3f(0.01, 0.14, 1.2);
    glVertex3f(-0.01, 0.14, 1.5);
    glVertex3f(0.01, 0.14, 1.5);

    glVertex3f(-0.01, 0.16, 1.2);
    glVertex3f(0.01, 0.16, 1.2);
    glVertex3f(-0.01, 0.16, 1.5);
    glVertex3f(0.01, 0.16, 1.5);

    glVertex3f(-0.01, 0.14, 1.2);
    glVertex3f(-0.01, 0.16, 1.2);
    glVertex3f(-0.01, 0.14, 1.5);
    glVertex3f(-0.01, 0.16, 1.5);

    glVertex3f(0.01, 0.14, 1.2);
    glVertex3f(0.01, 0.16, 1.2);
    glVertex3f(0.01, 0.14, 1.5);
    glVertex3f(0.01, 0.16, 1.5);

    glVertex3f(-0.01, 0.14, 1.2);
    glVertex3f(0.01, 0.14, 1.2);
    glVertex3f(-0.01, 0.14, 1.5);
    glVertex3f(0.01, 0.14, 1.5);

    glVertex3f(-0.01, 0.16, 1.2);
    glVertex3f(0.01, 0.16, 1.2);
    glVertex3f(-0.01, 0.16, 1.5);
    glVertex3f(0.01, 0.16, 1.5);

    // Śmiglo 4
    glVertex3f(-0.01, 0.14, 0.8);
    glVertex3f(0.01, 0.14, 0.8);
    glVertex3f(-0.01, 0.14, 1.1);
    glVertex3f(0.01, 0.14, 1.1);

    glVertex3f(-0.01, 0.16, 0.8);
    glVertex3f(0.01, 0.16, 0.8);
    glVertex3f(-0.01, 0.16, 1.1);
    glVertex3f(0.01, 0.16, 1.1);

    glVertex3f(-0.01, 0.14, 0.8);
    glVertex3f(-0.01, 0.16, 0.8);
    glVertex3f(-0.01, 0.14, 1.1);
    glVertex3f(-0.01, 0.16, 1.1);

    glVertex3f(0.01, 0.14, 0.8);
    glVertex3f(0.01, 0.16, 0.8);
    glVertex3f(0.01, 0.14, 1.1);
    glVertex3f(0.01, 0.16, 1.1);

    glVertex3f(-0.01, 0.14, 0.8);
    glVertex3f(0.01, 0.14, 0.8);
    glVertex3f(-0.01, 0.14, 1.1);
    glVertex3f(0.01, 0.14, 1.1);

    glVertex3f(-0.01, 0.16, 0.8);
    glVertex3f(0.01, 0.16, 0.8);
    glVertex3f(-0.01, 0.16, 1.1);
    glVertex3f(0.01, 0.16, 1.1);

  glEnd;
end;

procedure wiatrak;
begin
  slup;
  narysuj_szescian;
  narysuj_szescian2;

end;


procedure lodyga;
  var p:array [0..3] of f3d;
      norm,n:f3d;
begin
  with p[0] do begin x:=0.1; y:=0.1; z:=0 end;
  with p[1] do begin x:=-0.1; y:=0; z:=0 end;
  with p[2] do begin x:=0; y:=-0.1; z:=0 end;
  with p[3] do begin x:=0; y:=0; z:=1 end;

  glBindTexture(GL_TEXTURE_2D,tex1);
  glBegin(GL_TRIANGLES);
    norm:=il_wek(p[0],p[1],p[3]);
    n:=norm_wek(norm);
    glNormal3fv(@n);
    glTexCoord2f(0,0);
    glVertex3fv(@p[0]);
    glTexCoord2f(1,0);
    glVertex3fv(@p[1]);
    glTexCoord2f(0.5,1);
    glVertex3fv(@p[3]);

    norm:=il_wek(p[1],p[2],p[3]);
    n:=norm_wek(norm);
    glNormal3fv(@n);
    glTexCoord2f(0,0);
    glVertex3fv(@p[1]);
    glTexCoord2f(1,0);
    glVertex3fv(@p[2]);
    glTexCoord2f(0.5,1);
    glVertex3fv(@p[3]);

    norm:=il_wek(p[2],p[0],p[3]);
    n:=norm_wek(norm);
    glNormal3fv(@n);
    glTexCoord2f(0,0);
    glVertex3fv(@p[2]);
    glTexCoord2f(1,0);
    glVertex3fv(@p[0]);
    glTexCoord2f(0.5,1);
    glVertex3fv(@p[3]);
    glEnd;

end;


procedure kulka;
const
  kRadius = 0.08;
  kSlices = 20;
  kStacks = 20;
  kLeafCount = 50;
  kLeafLength = 0.3;
  kLeafWidth = 0.1;
var
  i, j: Integer;
  angle, angle2, leafAngle: Double;
begin

  glBindTexture(GL_TEXTURE_2D, tex3);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

  glBegin(GL_TRIANGLE_FAN);
  glTexCoord2f(0.5, 0.5);
  glVertex3f(0, 0, 0);

  for i := 0 to kSlices do
  begin
    angle := 2 * Pi * i / kSlices;
    glNormal3f(Sin(angle), Cos(angle), 0);
    glTexCoord2f(Sin(angle) * 0.5 + 0.5, Cos(angle) * 0.5 + 0.5);
    glVertex3f(kRadius * Sin(angle), kRadius * Cos(angle), 0);
  end;

  glEnd();

  glBegin(GL_TRIANGLE_STRIP);
  for j := 1 to kStacks - 1 do
  begin
    angle2 := Pi * j / kStacks;
    for i := 0 to kSlices do
    begin
      angle := 2 * Pi * i / kSlices;
      glTexCoord2f(i / kSlices, j / kStacks);
      glVertex3f(kRadius * Sin(angle) * Sin(angle2),
        kRadius * Cos(angle) * Sin(angle2),
        kRadius * Cos(angle2));
      glTexCoord2f(i / kSlices, (j + 1) / kStacks);
      glVertex3f(kRadius * Sin(angle) * Sin(angle2 + Pi / kStacks),
        kRadius * Cos(angle) * Sin(angle2 + Pi / kStacks),
        kRadius * Cos(angle2 + Pi / kStacks));
    end;
  end;
  glEnd();


  glBindTexture(GL_TEXTURE_2D, tex3);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  glBegin(GL_TRIANGLES);
  for i := 0 to kLeafCount - 1 do
  begin
    leafAngle := 2 * Pi * i / kLeafCount;
    glTexCoord2f(0.5, 0.5);
    glVertex3f(kRadius * Sin(leafAngle), kRadius * Cos(leafAngle), 0);
    glTexCoord2f(1, 0);
    glVertex3f(kRadius * Sin(leafAngle) + kLeafLength * Cos(leafAngle),
  kRadius * Cos(leafAngle) - kLeafLength * Sin(leafAngle),
  0);
glTexCoord2f(0, 1);
glVertex3f(kRadius * Sin(leafAngle) - kLeafWidth * Sin(leafAngle),
  kRadius * Cos(leafAngle) - kLeafWidth * Cos(leafAngle),
  0);
  end;
  glEnd();

  glDisable(GL_BLEND);
  end;


var petalAngle: Double = 0;

procedure kwiatek;

begin
glBindTexture(GL_TEXTURE_2D, tex3);
lodyga;
glPushMatrix;
glTranslatef(0, 0, 1);
glRotatef(petalAngle, 0, 0, 1);
kulka;
glPopMatrix;
petalAngle := petalAngle + 3.5;
end;



procedure drzewo_pien;
begin

glBindTexture(GL_TEXTURE_2D,tex6);
glBegin(GL_TRIANGLES); //pień drzewa, składający się z trzech wąskich trójkątów
glTexCoord2f(0,1);
glVertex3f(0.5,0.5,0);
glTexCoord2f(0,0);
glVertex3f(-0.5,0,0);
glTexCoord2f(1,1);
glVertex3f(0,0,5);
glTexCoord2f(0,1);
glVertex3f(-0.5,0,0);
glTexCoord2f(0,0);
glVertex3f(0,-0.5,0);
glTexCoord2f(1,1);
glVertex3f(0,0,5);
glTexCoord2f(0,1);
glVertex3f(0,-0.5,0);
glTexCoord2f(0,0);
glVertex3f(0.5,0.5,0);
glTexCoord2f(1,1);
glVertex3f(0,0,5);
glEnd;
end;
procedure drzewo_lisc;
begin
glBindTexture(GL_TEXTURE_2D,tex8);
glBegin(GL_Triangles); //lisc drzewa
glTexCoord2f(0,0);
glVertex3f(0.5,0.5,-0.18);
glTexCoord2f(0,1);
glVertex3f(-0.5,0,0.18);
glTexCoord2f(1,1);
glVertex3f(0,-0.5,0);

glEnd
end;

procedure drzewo_galezie; //gałęzie stworzone jako transformowany pień
  var i:integer;
  begin
  for i:=1 to 6 do
  begin
    glPushMatrix;  //działamy transformacjami tak jak mnożenie macierzy
    glTranslatef(0,0,i*0.20+2);               //4: podniesienie gałęzi wzdłuż pnia
    glRotatef(i*120,0,0,1);                     //3: obrócenie wokół osi Z
    glRotatef(70,1,0,0);                        //2: odchylenie od pionu
    glScalef(0.10*(5-i),0.10*(5-i),0.10*(5-i)); //1: skalowanie
    drzewo_pien;
    glPopMatrix;  //powrót stanu transformacji do pozycji wejściowej dla kolejnej gałęzi
  end;
  end;
procedure drzewo_liscie; //narysowanie 100 transformowanych liści wokół drzewa
  var i:integer;
  begin
  for i:=1 to 100 do
  begin
    glPushMatrix;  //transformacje działające na kolejny liść
    glRotatef(i*130,0,0,1);
    glTranslatef(0.15+0.1*sin(i),0.15+0.1*cos(i),i*0.013+3);
    glScalef(3,3,3);
    drzewo_lisc;
    glPopMatrix;  //powrót stanu transformacji do pozycji wejściowej dla kolejnego liścia
  end;
  end;


procedure tablica_losowa3; //generowanie lokalizacji wiatrakow
  var i:integer;
begin
  SetLength(tablos3,50); //wymiar tablicy z wiatraki
  for i:=0 to Length(tablos3)-1 do
  with tablos3[i] do
  begin
    repeat
      x:=(random(700))/10;       //wspolrzedna x w terenie
      y:=(random(700))/10;       //wspolrzedna y w terenie
      z:=ter[trunc(x),trunc(y)]-0.3;  //wysokosc z wzieta z terenu
      m:=random*5+1;                  //losowe skalowanie
      obr:=random(360);               //losowe obracanie
    until z>-0.6; //warunek zeby drzewo bylo ponad woda
  end;
end;

procedure tablica_losowa2; //generowanie lokalizacji budynkow
  var i:integer;
begin
  SetLength(tablos2,100); //wymiar tablicy z budynkami
  for i:=0 to Length(tablos2)-1 do
  with tablos2[i] do
  begin
    repeat
      x:=(random(700))/10;       //wspolrzedna x w terenie
      y:=(random(700))/10;       //wspolrzedna y w terenie
      z:=ter[trunc(x),trunc(y)]-0.3;  //wysokosc z wzieta z terenu
      m:=random*5+1;                  //losowe skalowanie
      obr:=random(360);               //losowe obracanie
    until z>-0.6; //warunek zeby drzewo bylo ponad woda
  end;
end;

procedure tablica_losowa; //generowanie lokalizacji drzew
  var i:integer;
begin
  SetLength(tablos,100);
  for i:=0 to Length(tablos)-1 do
  with tablos[i] do
  begin
    repeat
      x:=(random(700))/10;
      y:=(random(700))/10;
      z:=ter[trunc(x),trunc(y)]-0.5;
      m:=random*7+2;
      obr:=random(360);
    until z>-0.6;
  end;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
tablica_losowa;
  OpenGLControl1.SwapBuffers
end;

procedure TForm1.OpenGLControl1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  var i:integer;
        d,dgr,x,y:single;
        f:boolean;
        pozm: TPoz;
  begin
  pozm:=poz; f:=false;
  dgr:=0.5;
  case key of
  VK_UP:begin
          poz.x:=poz.x+poz.xw/2;
          poz.y:=poz.y+poz.yw/2;
          poz.z:=poz.z+poz.zw/2;
          for i:=0 to Length(tablos)-1 do with tablos[i] do
          begin d:=sqrt(sqr(x-poz.x)+sqr(y-poz.y));
            if d<dgr then f:=true
          end;
          for i:=0 to Length(tablos2)-1 do with tablos2[i] do
          begin d:=sqrt(sqr(x-poz.x)+sqr(y-poz.y));
            if d<dgr then f:=true
          end;
          for i:=0 to Length(tablos3)-1 do with tablos3[i] do
          begin d:=sqrt(sqr(x-poz.x)+sqr(y-poz.y));
            if d<dgr then f:=true
          end;
          if f then begin pozm.x:=poz.x-poz.xw/5;
                          pozm.y:=poz.y-poz.yw/5;
                          pozm.z:=poz.z-poz.zw/5 end;
        end;
  VK_DOWN:begin
            poz.x:=poz.x-poz.xw/2;
            poz.y:=poz.y-poz.yw/2;
            poz.z:=poz.z-poz.zw/2;
            for i:=0 to Length(tablos)-1 do with tablos[i] do
            begin d:=sqrt(sqr(x-poz.x)+sqr(y-poz.y));
              if d<dgr then f:=true
            end;
            for i:=0 to Length(tablos2)-1 do with tablos2[i] do
            begin d:=sqrt(sqr(x-poz.x)+sqr(y-poz.y));
              if d<dgr then f:=true
            end;
            for i:=0 to Length(tablos3)-1 do with tablos3[i] do
            begin d:=sqrt(sqr(x-poz.x)+sqr(y-poz.y));
              if d<dgr then f:=true
            end;
            if f then begin pozm.x:=poz.x+poz.xw/5;
                            pozm.y:=poz.y+poz.yw/5;
                            pozm.z:=poz.z+poz.zw/5 end;
          end;
  VK_LEFT:begin
            poz.k:=poz.k+0.6*pi/200; if poz.k>2*pi then poz.k:=0;
            x:=-sin(poz.k);
            y:=cos(poz.k);
            poz.xw:=x; poz.yw:=y
          end;
  VK_RIGHT:begin
             poz.k:=poz.k-0.6*pi/200; if poz.k<0 then poz.k:=2*pi;
             x:=-sin(poz.k);
             y:=cos(poz.k);
             poz.xw:=x; poz.yw:=y
           end;
  end;
  if (poz.x>-65) and (poz.x<65) and (poz.y>-65) and (poz.y<65) then
  poz.z:=ter[round(poz.x),round(poz.y)]-2 else poz.z:=-5;
  if f then poz:=pozm;
  OpenGLControl1Paint(self);
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
 k:=0;  k1:=0;
  teren_wykonaj(500,500,1.5,0.05,0.05,0.25);
  OpenGLControl1.MultiSampling:=2;
  OpenGLControl1.AutoResizeViewport:=true;
  OpenGLControl1.Invalidate;
  tablica_losowa;
  tablica_losowa2;
  tablica_losowa3;
  Color := ColorToRGB(clSkyBlue);
end;

procedure TForm1.Dodaj_teksturyClick(Sender: TObject);
begin
  if bmp1<>nil then bmp1.Free;
  bmp1:=TBitmap.Create;
  LoadTexture('lod.jpg',bmp1,tex1);
  if glIsTexture(tex1)=GL_TRUE then Label2.Caption:='jest tekstura | '
                               else Label2.Caption:='brak tekstury | ';

  if bmp3<>nil then bmp3.Free;
  bmp3:=TBitmap.Create;
  LoadTexture('roz.jpg',bmp3,tex3);
  if glIsTexture(tex3)=GL_TRUE then Label4.Caption:='jest tekstura | '
                               else Label4.Caption:='brak tekstury | ';
  if bmp4<>nil then bmp4.Free;
  bmp4:=TBitmap.Create;
  LoadTexture('metal.jpg',bmp4,tex4);
  if glIsTexture(tex4)=GL_TRUE then Label5.Caption:='jest tekstura '
                               else Label5.Caption:='brak tekstury ';
  if bmp5<>nil then bmp5.Free;
   bmp5:=TBitmap.Create;
   LoadTexture('trawa.jpg',bmp5,tex5);
   if glIsTexture(tex5)=GL_TRUE then Label3.Caption:='jest tekstura '
                               else Label3.Caption:='brak tekstury ';

   if bmp6<>nil then bmp6.Free;
   bmp6:=TBitmap.Create;
   LoadTexture('drewno.jpg',bmp6,tex6);

   if bmp8<>nil then bmp8.Free;
   bmp8:=TBitmap.Create;
   LoadTexture('Lisc.jpg',bmp8,tex8);

end;

procedure TForm1.Usun_teksturyClick(Sender: TObject);
begin
  glDeleteTextures(1,@tex1); tex1:=0;
  Label2.Caption:='brak tekstury | ';
  glDeleteTextures(5,@tex5); tex5:=0;
  Label3.Caption:='brak tekstury | ';
  glDeleteTextures(3,@tex3); tex3:=0;
  Label4.Caption:='brak tekstury | ';
  glDeleteTextures(4,@tex4); tex4:=0;
  Label5.Caption:=' brak tekstury ';
  glDeleteTextures(6,@tex6); tex6:=0;
  glDeleteTextures(8,@tex8); tex8:=0;
end;

procedure TForm1.OpenGLControl1Paint(Sender: TObject);
  var error:LongInt;
         i:integer;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glClearColor(0.529, 0.808, 0.922, 1.0); // Set sky blue color
  glLoadIdentity();
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(xpoz/15-50,Width/Height,0.1,1000);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

  with poz do gluLookAt(x,y,-z,x+xw,y+yw,-z+zw,0,0,-1);
  OpenGLControl1.Invalidate;
  glClearColor(0.5,0.6,0.5,1);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glEnable(GL_DEPTH_test);
  glEnable(GL_COLOR_MATERIAL);
  oswietlenie;
  glRotatef(ypoz,0,0,1);
  Teren_rysuj;


  for i:=0 to Length(tablos)-1 do with tablos[i] do
  begin
    glPushMatrix;
    glScalef(m,m,m);
    glRotatef(obr,0,0,1);
    glTranslatef(x,y,0);
    drzewo_pien;
    drzewo_galezie;
    drzewo_liscie;
    glPopMatrix;
  end;
  for i:=0 to Length(tablos2)-1 do with tablos2[i] do
  begin
    glPushMatrix;
    glScalef(8,8,8);
    glRotatef(z,0,0,1);
    glTranslatef(x,y,0);
    kwiatek;
    glPopMatrix;
  end;
  for i:=0 to Length(tablos3)-1 do with tablos3[i] do
  begin
    glPushMatrix;
    glScalef(3,3,3);
    glRotatef(obr,0,0,1);
    glTranslatef(x,y,0);
    wiatrak;
    glPopMatrix;
  end;

  OpenGLControl1.SwapBuffers;
  error:=glGetError();
  label1.Caption:=ISO_8859_2ToUTF8(gluErrorString(error));
end;

procedure TForm1.OpenGLControl1Resize(Sender: TObject);
begin

end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
k1 := k1 + 0.05;
if k1 >= 360 then
k1 := 0;
OpenGLControl1Paint(Self);
OpenGLControl1.Invalidate;
end;

end.



