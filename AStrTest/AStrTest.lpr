program AStrTest;

{$mode delphi}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  FastMM4,
  Classes,
  SysUtils,
  CustApp { you can add units after this };

type

  { TAStrTestApplication }

  TAStrTestApplication = class(TCustomApplication)
  private
    procedure TestLargeAnsiStrings(SizeInKb: Integer);
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

  { TAStrTestApplication }

  procedure TAStrTestApplication.TestLargeAnsiStrings(SizeInKb: Integer);
  const
    Filler = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz~!@#$%^&*()_+{}[]|`\/?.,<>';
  var
    I, J: Integer;
    Buf, S: AnsiString;
  begin
    Writeln(Format('Prepearing buffer of %dKb', [SizeInKb]));
    Buf := Filler;
    // Let's prepare buffer first
    while Length(Buf) < SizeInKb * 1024 do
      AppendStr(Buf, Filler);
    // And now we a ready to append buffer to string and check reallocation
    Write('Expanding string...0');
    S := Buf;
    for I := 1 to 9 do begin
      Write(', ', I);
      SetLength(S, Succ(I) * Length(Buf));
      // Copy Buf including trailing #0
      Move(PChar(Buf)^, PByteArray(S)[I * Length(Buf)], Succ(Length(Buf)));
      for J := 0 to Pred(I) do
        if strlcomp(PChar(@PByteArray(S)[J * Length(Buf)]), PChar(Buf), Length(Buf)) <> 0 then
          raise Exception.CreateFmt(
            'Invalid relocation when Length(S) = %d, J = %d',
            [Length(S), J]);
    end;
    Writeln(' - done successfully')
  end;

  procedure TAStrTestApplication.DoRun;
  var
    ErrorMsg: string;
  begin
    // quick check parameters
    ErrorMsg := CheckOptions('h', 'help');
    if ErrorMsg <> '' then
    begin
      ShowException(Exception.Create(ErrorMsg));
      Terminate;
      Exit;
    end;

    // parse parameters
    if HasOption('h', 'help') then
    begin
      WriteHelp;
      Terminate;
      Exit;
    end;

    { add your program here }
    TestLargeAnsiStrings(50);

    // stop program loop
    Terminate;
  end;

  constructor TAStrTestApplication.Create(TheOwner: TComponent);
  begin
    inherited Create(TheOwner);
    StopOnException := True;
  end;

  destructor TAStrTestApplication.Destroy;
  begin
    inherited Destroy;
  end;

  procedure TAStrTestApplication.WriteHelp;
  begin
    { add your help code here }
    writeln('Usage: ', ExeName, ' -h');
  end;

var
  Application: TAStrTestApplication;
begin
  Application := TAStrTestApplication.Create(nil);
  Application.Title := 'AStr Test Application';
  Application.Run;
  Application.Free;
end.
