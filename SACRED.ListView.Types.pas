unit SACRED.ListView.Types;

interface

uses
  FMX.ListView.Types, FMX.Graphics, FMX.TextLayout, FMX.Types, System.UITypes, System.Classes,
  System.Types;

type

  TElemetnLayout = (ilNone, ilLeft, ilRight, ilCenter, ilBotton, ilTop);

  TElementPosition = record
    Heigth : Single;
    Width : Single;
    PaddingLeft : Single;
    PaddingTop : Single;
    PaddingRight : Single;
    PaddingBotton : Single;
    constructor Create(aHeigth, aWidth, aPaddingLeft, aPaddingTop : Single; aPaddingRight: Single = 0; aPaddingBotton : Single = 0); overload;
    constructor CreateLine(aPaddingLeft, aPaddingTop : Single; aPaddingRight: Single = 0; aPaddingBotton : Single = 0); overload;
  end;

  TBaseItem = class(TListItemText)
  private
    FFillSpaceDebug: Boolean;
    FPaddings: TBounds;
    FDebugColor : TAlphaColor;
    FDebugOptical : Single;
    FDebugRec: Boolean;
    FAlign: TElemetnLayout;
    FBlockRes: Boolean;
    FMyLocalRect: TRectF;
    FAutoHeigth: Boolean;
    FChainItem: TBaseItem;
    procedure SetAlign(const Value: TElemetnLayout);
  public
    constructor Create(const AOwner: TListItem); reintroduce; overload; virtual;
    destructor Destroy; override;
    procedure CalcHeigth(aWidth : Single; aAddition : Single); virtual;
    procedure CalculateLocalRect(const DestRect: TRectF; const SceneScale: Single; const DrawStates: TListItemDrawStates; const Item: TListItem); override;
    property Align: TElemetnLayout read FAlign write SetAlign;
    property Paddings: TBounds read FPaddings write FPaddings;
    constructor Create(const AOwner: TListItem; aName : String; aElementPosition : TElementPosition); reintroduce; overload; virtual;
    property FillSpaceDebug: Boolean read FFillSpaceDebug write FFillSpaceDebug;
    procedure Render(const Canvas: TCanvas; const DrawItemIndex: Integer; const DrawStates: TListItemDrawStates; const Resources: TListItemStyleResources; const Params: TListItemDrawable.TParams; const SubPassNo: Integer = 0); override;
    function ApplyStyle : Single; virtual;
    function CalcMaxHeigthAlign(aMaxHeigth : Single; aItemSpace : TBounds) : Single;
    procedure CorrectAlign(aMaxHeigth : Single; aItemSpace : TBounds); virtual;
    property DebugRec: Boolean read FDebugRec write FDebugRec;
    property BlockRes: Boolean read FBlockRes write FBlockRes;
    property AutoHeigth: Boolean read FAutoHeigth write FAutoHeigth;
    property ChainItem: TBaseItem read FChainItem write FChainItem;
  end;

  TTextItem= class(TBaseItem)
  private
    type
      TFontSettings = record
        Family: string;
        Size: Single;
        Style: TFontStyles;
      end;
  private
    FFontX : TFont;
    FFontSettings: TFontSettings;
    FTextLayout : TTextLayout;
    LayoutChanged : Boolean;
    FText: String;
    FTextColor: TAlphaColor;
    FTrimming: TTextTrimming;
    FTextShadowColor: TAlphaColor;
    FTextVertAlign: TTextAlign;
    FTextAlign: TTextAlign;
    FWordWrap: Boolean;
    FTextShadowOffsetX: TPosition;
    FSelectedTextColor: TAlphaColor;
    function GetFont: TFont;
    function GetShadowOffset: TPosition;
    procedure SetSelectedTextColor(const Value: TAlphaColor);
    procedure SetText(const Value: string);
    procedure SetTextAlign(const Value: TTextAlign);
    procedure SetTextColor(const Value: TAlphaColor);
    procedure SetTextShadowColor(const Value: TAlphaColor);
    procedure SetTextVertAlign(const Value: TTextAlign);
    procedure SetTrimming(const Value: TTextTrimming);
    procedure SetWordWrap(const Value: Boolean);
    procedure FontChanged(Sender : TObject);
    function FontSettingsSnapshot: TFontSettings;
    procedure TextShadowOffsetChanged(Sender : TObject);
  public

    constructor Create(const AOwner: TListItem); override;
    destructor Destroy; override;
    procedure CalcHeigth(aWidth : Single; aAddition : Single); override;
    property Font: TFont read GetFont;
    property Text: string read FText write SetText;
    property TextAlign: TTextAlign read FTextAlign write SetTextAlign;
    property TextVertAlign: TTextAlign read FTextVertAlign write SetTextVertAlign;
    property WordWrap: Boolean read FWordWrap write SetWordWrap;
    property TextColor: TAlphaColor read FTextColor write SetTextColor;
    property SelectedTextColor: TAlphaColor read FSelectedTextColor write SetSelectedTextColor;
    property TextShadowColor: TAlphaColor read FTextShadowColor write SetTextShadowColor;
    property TextShadowOffset: TPosition read GetShadowOffset;
    property Trimming: TTextTrimming read FTrimming write SetTrimming;
    procedure Render(const Canvas: TCanvas; const DrawItemIndex: Integer; const DrawStates: TListItemDrawStates; const Resources: TListItemStyleResources; const Params: TListItemDrawable.TParams; const SubPassNo: Integer = 0); override;
  end;

  TCircleTextItem = class(TTextItem)
  private
    FFillColor: TAlphaColor;
  public
    procedure Render(const Canvas: TCanvas; const DrawItemIndex: Integer; const DrawStates: TListItemDrawStates; const Resources: TListItemStyleResources; const Params: TListItemDrawable.TParams; const SubPassNo: Integer = 0); override;
    property FillColor: TAlphaColor read FFillColor write FFillColor;

  end;

  TImageItem = class(TBaseItem)
  private
    FImage: TBitmap;
    procedure SetImage(const Value: TBitmap);
  public

    constructor Create(const AOwner: TListItem); override;
    destructor Destroy; override;
    property Image: TBitmap read FImage write SetImage;
    procedure Render(const Canvas: TCanvas; const DrawItemIndex: Integer; const DrawStates: TListItemDrawStates; const Resources: TListItemStyleResources; const Params: TListItemDrawable.TParams; const SubPassNo: Integer = 0); override;
  end;

  TLineItem = class(TBaseItem)
  private
    FColorLine: TAlphaColor;
    FThickness: Single;
  public

    constructor Create(const AOwner: TListItem; aName : String; aElementPosition : TElementPosition); override;
    procedure CalculateLocalRect(const DestRect: TRectF; const SceneScale: Single; const DrawStates: TListItemDrawStates; const Item: TListItem); override;
    procedure CorrectAlign(aMaxHeigth: Single; aItemSpace : TBounds); override;
    property ColorLine: TAlphaColor read FColorLine write FColorLine;
    property Thickness: Single read FThickness write FThickness;
    procedure Render(const Canvas: TCanvas; const DrawItemIndex: Integer; const DrawStates: TListItemDrawStates; const Resources: TListItemStyleResources; const Params: TListItemDrawable.TParams; const SubPassNo: Integer = 0); override;
  end;

  TCircleImageItem = class(TBaseItem)
  private
    FImage: TBitmap;
    FOriginImage : TBitmap;
    FStroke: Boolean;
    FStrokeColor: TAlphaColor;
    FStrokeThickness: Single;
    procedure SetImage(const Value: TBitmap);
    procedure SetStrokeThickness(const Value: Single);
  public

    constructor Create(const AOwner: TListItem); override;
    destructor Destroy; override;
    property Image: TBitmap read FImage write SetImage;
    property Stroke: Boolean read FStroke write FStroke;
    property StrokeColor: TAlphaColor read FStrokeColor write FStrokeColor;
    property StrokeThickness: Single read FStrokeThickness write SetStrokeThickness;
    procedure Render(const Canvas: TCanvas; const DrawItemIndex: Integer; const DrawStates: TListItemDrawStates; const Resources: TListItemStyleResources; const Params: TListItemDrawable.TParams; const SubPassNo: Integer = 0); override;
  end;

implementation

uses
  System.SysUtils, FMX.Objects;

function Blend(const Color1, Color2: TAlphaColor; const Alpha: Single): TAlphaColor;

  function BlendComponent(const Value1, Value2: Integer; const Alpha: Single): Integer; inline;
  begin
    Result := Value1 + Round((Value2 - Value1) * Alpha);
  end;

begin
  TAlphaColorRec(Result).R := BlendComponent(TAlphaColorRec(Color1).R, TAlphaColorRec(Color2).R, Alpha);
  TAlphaColorRec(Result).G := BlendComponent(TAlphaColorRec(Color1).G, TAlphaColorRec(Color2).G, Alpha);
  TAlphaColorRec(Result).B := BlendComponent(TAlphaColorRec(Color1).B, TAlphaColorRec(Color2).B, Alpha);
  TAlphaColorRec(Result).A := BlendComponent(TAlphaColorRec(Color1).A, TAlphaColorRec(Color2).A, Alpha);
end;

{ TBaseItem }

function TBaseItem.ApplyStyle : Single;
begin
  Self.PlaceOffset.X := Self.Paddings.Left;
  Self.PlaceOffset.Y := Self.Paddings.Top;
//  Self.Height        := Self.Height - Self.Paddings.Bottom;
  Self.Width         := Self.Width - Self.Paddings.Right;

  Result := Self.PlaceOffset.Y + Self.Height;
end;

procedure TBaseItem.CalcHeigth;
begin

end;

function TBaseItem.CalcMaxHeigthAlign;
  function CalcSide : Single;
  begin
    Result := -1;
    if Self.Height+Self.PlaceOffset.Y+aItemSpace.Top+aItemSpace.Bottom > aMaxHeigth then
    begin
      Result := Self.Height+Self.PlaceOffset.Y+aItemSpace.Top+aItemSpace.Bottom;
    end
  end;

begin
  case Align of
    ilNone: Result := aMaxHeigth;
    ilLeft: Result := CalcSide;
    ilRight: Result := CalcSide;
    ilCenter: Result := aMaxHeigth;
    ilBotton: Result := CalcSide;
    else
    begin
      Result := aMaxHeigth;
    end;
  end;
end;

procedure TBaseItem.CalculateLocalRect(const DestRect: TRectF; const SceneScale: Single; const DrawStates: TListItemDrawStates; const Item: TListItem);
begin
  DestRect.Width := DestRect.Width - Self.Paddings.Right;
  DestRect.Height := DestRect.Height - Self.Paddings.Bottom;
  inherited;
end;

procedure TBaseItem.CorrectAlign;
begin
  case Align of
    ilNone: ;
    ilLeft: Self.Height := aMaxHeigth;
    ilRight: Self.Height := aMaxHeigth;
    ilCenter: ;
  end;
end;

constructor TBaseItem.Create(const AOwner: TListItem; aName: String; aElementPosition: TElementPosition);
begin
  Create(AOwner);
  Self.Name            := aName;
  FFillSpaceDebug      := False;
  Self.Height          := aElementPosition.Heigth;
  Self.Width           := aElementPosition.Width-aElementPosition.PaddingRight;
  Self.Paddings.Left   := aElementPosition.PaddingLeft;
  Self.Paddings.Top    := aElementPosition.PaddingTop;
  Self.Paddings.Right  := aElementPosition.PaddingRight;
  Self.Paddings.Bottom := aElementPosition.PaddingBotton;
//  Self.PlaceOffset.X := Self.Paddings.Left;
//  Self.PlaceOffset.Y := Self.Paddings.Top;
end;

destructor TBaseItem.Destroy;
begin
  if Assigned(FPaddings) then
  begin
    FreeAndNil(FPaddings);
  end;
  inherited;
end;

constructor TBaseItem.Create(const AOwner: TListItem);
begin
  inherited;
  FBlockRes := False;
  FPaddings   := TBounds.Create(TRect.Empty);
  FDebugColor := TAlphaColorRec.Brown;
  FDebugOptical := 0.2;
//  FDebugRec := {$IFDEF DEBUG}true;{$ELSE}false;{$ENDIF}
end;

procedure TBaseItem.Render(const Canvas: TCanvas; const DrawItemIndex: Integer; const DrawStates: TListItemDrawStates; const Resources: TListItemStyleResources; const Params: TListItemDrawable.TParams;
  const SubPassNo: Integer);
var
  MarginBrush : TBrush;
begin
//  TListItemDrawable(Self).Render(Canvas, DrawItemIndex, DrawStates, Resources, Params, SubPassNo);
  if FDebugRec then
  begin
    MarginBrush := TBrush.Create(TBrushKind.Solid, FDebugColor);
    Canvas.FillRect(LocalRect, 2, 2, AllCorners, FDebugOptical, MarginBrush);
    FreeAndNil(MarginBrush);
  end;
end;

procedure TBaseItem.SetAlign(const Value: TElemetnLayout);
begin
  FAlign := Value;
  case Value of
    ilNone: ;
    ilLeft:
      begin
        Self.PlaceOffset.X := 0;
        Self.PlaceOffset.Y := 0;
      end;
    ilRight: ;
    ilCenter: ;
  end;
end;

{ TTextItem }

procedure TTextItem.CalcHeigth;
var
  aText: TTextLayout;
  iWidth: Single;
begin
  inherited;
  if Self.Width = 0 then
  begin
    iWidth := aWidth-Self.Paddings.Left-Self.Paddings.Right+Self.Paddings.Left;
  end
  else
  begin
    iWidth := Self.Width;
  end;
    aText := TTextLayoutManager.DefaultTextLayout.Create;
    aText.BeginUpdate;
    try
      aText.HorizontalAlign := FTextAlign;
      aText.VerticalAlign := FTextVertAlign;
      aText.Font := Font;
      aText.RightToLeft := False;
      aText.MaxSize := TPointF.Create(iWidth, 2000);
      aText.Text := FText;
      aText.Trimming := FTrimming;
      aText.WordWrap := FWordWrap;
    finally
      aText.EndUpdate;
      Self.Height := aText.Height;
      FreeAndNil(aText);
    end;
end;

constructor TTextItem.Create(const AOwner: TListItem);
begin
  inherited;
  Self.TextColor         := TAlphaColorRec.Black;
  Self.TextAlign         := TTextAlign.Center;
  Self.TextVertAlign     := TTextAlign.Center;
  Self.SelectedTextColor := TAlphaColorRec.Black;
  Self.TextShadowColor   := TAlphaColorRec.Black;
  Self.Trimming          := TTextTrimming.Character;
  Self.WordWrap          := true;
  Self.AutoHeigth        := False;
end;

destructor TTextItem.Destroy;
begin
  if Assigned(FFontX) then
  begin
    FreeAndNil(FFontX);
  end;
  if Assigned(FTextLayout) then
  begin
    FreeAndNil(FTextLayout);
  end;
  inherited;
end;

procedure TTextItem.FontChanged;
var
  NewSettings: TFontSettings;
begin
  NewSettings := FontSettingsSnapshot;
  FFontSettings := NewSettings;
  LayoutChanged := True;
  Invalidate;
end;

function TTextItem.FontSettingsSnapshot: TFontSettings;
begin
  Result.Size := FFontX.Size;
  Result.Style := FFontX.Style;
  Result.Family := FFontX.Family;
end;

function TTextItem.GetFont: TFont;
begin
  if FFontX = nil then
  begin
    FFontX := TFont.Create;
    FFontX.OnChanged := FontChanged;
  end;
  FFontSettings := FontSettingsSnapshot;
  Result := FFontX;
end;

function TTextItem.GetShadowOffset: TPosition;
begin
  if FTextShadowOffsetX = nil then
  begin
    FTextShadowOffsetX := TPosition.Create(TPointF.Create(0, 1));
    FTextShadowOffsetX.OnChange := TextShadowOffsetChanged;
  end;
  Result := FTextShadowOffsetX;
end;

procedure TTextItem.Render(const Canvas: TCanvas; const DrawItemIndex: Integer; const DrawStates: TListItemDrawStates; const Resources: TListItemStyleResources; const Params: TListItemDrawable.TParams; const SubPassNo: Integer);
var
  CurColor: TAlphaColor;
  SelectedAlpha, LOpacity: Single;
begin
  inherited;
  if SubPassNo <> 0 then
  begin
    Exit;
  end;

  if FTextLayout = nil then
  begin
    FTextLayout := TTextLayoutManager.TextLayoutByCanvas(Canvas.ClassType).Create(Canvas);
    LayoutChanged := True
  end;

  if not LayoutChanged then
  begin
    LayoutChanged := (FTextLayout.MaxSize.X <> LocalRect.Width) or (FTextLayout.MaxSize.Y <> LocalRect.Height);
  end;

  CurColor := FTextColor;
  LOpacity := Params.AbsoluteOpacity;
  if TListItemDrawState.Selected in DrawStates then
  begin
    SelectedAlpha := Params.ItemSelectedAlpha;

    if (SelectedAlpha > 0) and (SelectedAlpha < 1) then
    begin
      CurColor := Blend(CurColor, FSelectedTextColor, SelectedAlpha)
    end
    else if SelectedAlpha >= 1 then
    begin
      CurColor := FSelectedTextColor;
    end;
  end;

  if (not LayoutChanged) and (FTextLayout.Color <> CurColor) then
  begin
    LayoutChanged := True;
  end;

  if LayoutChanged then
  begin
    FTextLayout.BeginUpdate;
    try
      FTextLayout.HorizontalAlign := FTextAlign;
      FTextLayout.VerticalAlign := FTextVertAlign;
      FTextLayout.Font := Font;
      FTextLayout.Color := CurColor;
      FTextLayout.RightToLeft := False;
      FTextLayout.MaxSize := TPointF.Create(LocalRect.Width, LocalRect.Height);
      FTextLayout.Text := FText;
      FTextLayout.Trimming := FTrimming;
      FTextLayout.WordWrap := FWordWrap;
    finally
      FTextLayout.EndUpdate;
      LayoutChanged := False;
    end;
  end;

  {Мне не нравится как он ресует тень, да ещё и он всегда это делат, ФЕЕЕЕЕЕ}
//  if TAlphaColorRec(FTextShadowColor).A > 0 then
//  begin
//    FTextLayout.BeginUpdate;
//    FTextLayout.Opacity := LOpacity;
//    FTextLayout.Color := FTextShadowColor;
//    FTextLayout.TopLeft := LocalRect.TopLeft + TextShadowOffset.Point;
//    FTextLayout.EndUpdate;
//    FTextLayout.RenderLayout(Canvas);
//
//    FTextLayout.BeginUpdate;
//    FTextLayout.Color := CurColor;
//    FTextLayout.EndUpdate;
//  end;

  FTextLayout.BeginUpdate;
  FTextLayout.Opacity := LOpacity;
  FTextLayout.TopLeft := LocalRect.TopLeft;
  FTextLayout.EndUpdate;
  FTextLayout.RenderLayout(Canvas);
end;

procedure TTextItem.SetSelectedTextColor(const Value: TAlphaColor);
begin
  if FSelectedTextColor <> Value then
  begin
    FSelectedTextColor := Value;
    LayoutChanged := True;
    Invalidate;
  end;
end;

procedure TTextItem.SetText(const Value: string);
begin
  if FText <> Value then
  begin
    TListItemText(Self).Text := Value;
    FText := Value;
    LayoutChanged := True;
    Invalidate;
  end;
end;

procedure TTextItem.SetTextAlign(const Value: TTextAlign);
begin
  if FTextAlign <> Value then
  begin
    FTextAlign := Value;
    LayoutChanged := True;
    Invalidate;
  end;
end;

procedure TTextItem.SetTextColor(const Value: TAlphaColor);
begin
  if FTextColor <> Value then
  begin
    FTextColor := Value;
    LayoutChanged := True;
    Invalidate;
  end;
end;

procedure TTextItem.SetTextShadowColor(const Value: TAlphaColor);
begin
  if FTextShadowColor <> Value then
  begin
    FTextShadowColor := Value;
    LayoutChanged := True;
    Invalidate;
  end;
end;

procedure TTextItem.SetTextVertAlign(const Value: TTextAlign);
begin
  if FTextVertAlign <> Value then
  begin
    FTextVertAlign := Value;
    LayoutChanged := True;
    Invalidate;
  end;
end;

procedure TTextItem.SetTrimming(const Value: TTextTrimming);
begin
  if FTrimming <> Value then
  begin
    FTrimming := Value;
    LayoutChanged := True;
    Invalidate;
  end;
end;

procedure TTextItem.SetWordWrap(const Value: Boolean);
begin
  if FWordWrap <> Value then
  begin
    FWordWrap := Value;
    LayoutChanged := True;
    Invalidate;
  end;
end;

procedure TTextItem.TextShadowOffsetChanged(Sender: TObject);
begin
  Invalidate;
end;

{ TImageItem }

constructor TImageItem.Create(const AOwner: TListItem);
begin
  inherited;
  FDebugColor   := TAlphaColorRec.Chocolate;
  FDebugOptical := 0.2;
  FDebugRec := True;
end;

destructor TImageItem.Destroy;
begin
  if BlockRes then
  begin
    if Assigned(FImage) then
    begin
      FreeAndNil(FImage);
    end;
  end;
  inherited;
end;

procedure TImageItem.Render(const Canvas: TCanvas; const DrawItemIndex: Integer; const DrawStates: TListItemDrawStates; const Resources: TListItemStyleResources; const Params: TListItemDrawable.TParams; const SubPassNo: Integer);
begin
  inherited;
  if LocalRect.Height > Image.Height then
  begin
    Canvas.DrawBitmap(Image, Image.BoundsF, Image.BoundsF.CenterAt(LocalRect), Params.AbsoluteOpacity);
  end
  else
  begin
    Canvas.DrawBitmap(Image, Image.BoundsF, LocalRect, Params.AbsoluteOpacity);
  end;
end;

procedure TImageItem.SetImage(const Value: TBitmap);
begin
  if BlockRes then
  begin
    if Assigned(FImage) then
    begin
      FreeAndNil(FImage);
    end;
    FImage := TBitmap.Create();
    FImage.Assign(Value);
  end
  else
  begin
    FImage := Value;
  end;
end;

{ TElementPosition }

constructor TElementPosition.Create(aHeigth, aWidth, aPaddingLeft, aPaddingTop, aPaddingRight, aPaddingBotton: Single);
begin
  Heigth        := aHeigth;
  Width         := aWidth;
  PaddingLeft   := aPaddingLeft;
  PaddingTop    := aPaddingTop;
  PaddingRight  := aPaddingRight;
  PaddingBotton := aPaddingBotton;
end;

constructor TElementPosition.CreateLine(aPaddingLeft, aPaddingTop, aPaddingRight, aPaddingBotton: Single);
begin
  Create(-1, -1, aPaddingLeft, aPaddingTop, aPaddingRight, aPaddingBotton);
end;

{ TCircleImageItem }

constructor TCircleImageItem.Create(const AOwner: TListItem);
begin
  inherited;
  FDebugColor      := TAlphaColorRec.Chocolate;
  FDebugOptical    := 0.5;
  FStrokeThickness := 0;
  FStrokeColor     := TAlphaColorRec.Maroon;
  FStroke          := False;
end;

destructor TCircleImageItem.Destroy;
begin
  if BlockRes then
  begin
    if Assigned(FImage) then
    begin
      FreeAndNil(FImage);
    end;
  end;
  if Assigned(FOriginImage) then
  begin
    FreeAndNil(FOriginImage);
  end;
  inherited;
end;

procedure TCircleImageItem.Render(const Canvas: TCanvas; const DrawItemIndex: Integer; const DrawStates: TListItemDrawStates; const Resources: TListItemStyleResources; const Params: TListItemDrawable.TParams;
  const SubPassNo: Integer);
var
  oRec: TCircle;
begin
  inherited;
  if Not Assigned(FOriginImage) then
  begin
    oRec := TCircle.Create(nil);
    try
      oRec.Height := FImage.Height{+Round(FStrokeThickness*2)};
      oRec.Width := FImage.Width{+Round(FStrokeThickness*2)};

      if Stroke then
      begin
        oRec.Stroke.Kind := TBrushKind.Solid;
        oRec.Stroke.Color := FStrokeColor;
        oRec.Stroke.Thickness := FStrokeThickness;
      end
      else
      begin
        oRec.Stroke.Kind := TBrushKind.None;
      end;

      oRec.Fill.Kind := TBrushKind.Bitmap;
      oRec.Fill.Bitmap.Bitmap.SetSize(FImage.Width{+Round(FStrokeThickness*2)}, FImage.Height{+Round(FStrokeThickness*2)});
      oRec.Fill.Bitmap.Bitmap.CopyFromBitmap(FImage, TRect.Create(0, 0, FImage.Width, FImage.Height), 0{Round(FStrokeThickness)}, 0{Round(FStrokeThickness)});
      FOriginImage := oRec.MakeScreenshot;
    finally
      FreeAndNil(oRec);
    end;
  end;

  if Assigned(FOriginImage) then
  begin
    if LocalRect.Height > FOriginImage.Height then
    begin
      Canvas.DrawBitmap(FOriginImage, FOriginImage.BoundsF, FOriginImage.BoundsF.CenterAt(LocalRect), Params.AbsoluteOpacity);
    end
    else
    begin
      Canvas.DrawBitmap(FOriginImage, FOriginImage.BoundsF, LocalRect, Params.AbsoluteOpacity);
    end;
  end;
end;

procedure TCircleImageItem.SetImage(const Value: TBitmap);
begin
  if BlockRes then
  begin
    if Assigned(FImage) then
    begin
      FreeAndNil(FImage);
    end;
    FImage := TBitmap.Create();
    FImage.Assign(Value);
  end
  else
  begin
    FImage := Value;
  end;
end;

procedure TCircleImageItem.SetStrokeThickness(const Value: Single);
begin
  Self.Paddings.Left :=   Self.Paddings.Left - FStrokeThickness;
  FStrokeThickness := Value;
  Self.Paddings.Left :=   Self.Paddings.Left + FStrokeThickness;
end;

{ TLineItem }

procedure TLineItem.CalculateLocalRect(const DestRect: TRectF; const SceneScale: Single; const DrawStates: TListItemDrawStates; const Item: TListItem);
begin
  DestRect.Width := DestRect.Width - Self.Paddings.Right - Self.Paddings.Left;
  inherited;
end;

procedure TLineItem.CorrectAlign;
begin
  inherited;
  case FAlign of
    ilBotton: Self.PlaceOffset.Y := aMaxHeigth - Self.Thickness + (aItemSpace.Bottom)-Self.Paddings.Bottom - aItemSpace.Top;
  end;
end;

constructor TLineItem.Create(const AOwner: TListItem; aName: String; aElementPosition: TElementPosition);
begin
  inherited;
  Opacity := 1;
  FColorLine := TAlphaColorRec.Maroon;
  FDebugRec := False;
  AOwner.Invalidate;
end;

procedure TLineItem.Render(const Canvas: TCanvas; const DrawItemIndex: Integer; const DrawStates: TListItemDrawStates; const Resources: TListItemStyleResources; const Params: TListItemDrawable.TParams;
  const SubPassNo: Integer);
var
  p1,p2:TPointF;
begin
  inherited;
  Canvas.Stroke.Color := FColorLine;
  Canvas.Stroke.Kind := TBrushKind.Solid;
  p1:=LocalRect.TopLeft;
  p2:=LocalRect.BottomRight;
  p2.Y := p1.Y;
  Canvas.Stroke.Thickness := Thickness;
  Canvas.DrawLine(p1, p2, Opacity);
end;

{ TCircleTextItem }

procedure TCircleTextItem.Render(const Canvas: TCanvas; const DrawItemIndex: Integer; const DrawStates: TListItemDrawStates; const Resources: TListItemStyleResources; const Params: TListItemDrawable.TParams; const SubPassNo: Integer);
var
  oStrok : TStrokeBrush;
begin
  oStrok := TStrokeBrush.Create(TBrushKind.Solid, FFillColor);
  oStrok.Thickness := 2;
  Canvas.FillEllipse(TRectF.Create(TPointF.Create(LocalRect.Left, LocalRect.Top), LocalRect.Width, LocalRect.Height), 1, oStrok);
  FreeAndNil(oStrok);
  inherited;

end;

end.








































