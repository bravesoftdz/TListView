unit SACRED.ListView;

interface

uses
  System.Generics.Collections, FMX.ListView.Types, FMX.Types, FMX.Graphics, System.SysUtils, FMX.ListView, FMX.ListView.Appearances, FMX.TextLayout,
  System.Types, System.UITypes, Math, System.Classes, FMX.Controls, System.Rtti, FMX.SearchBox, SACRED.ListView.Types, System.Threading,
  FMX.StdCtrls;

type
  ITemplateElement = interface
  ['{9C3FDF65-1FCB-4E74-9140-E7E95F270F67}']
    procedure TemplateIncomes(aItemList: TListViewItem);
  end;

  TListViewTemplate = procedure(aItemList: TListViewItem) of Object;
  TSearchEnter = procedure(Sender : TObject; aText : String) of Object;

  TRowElementItem = class
  private
    FName: String;
    FValue: TValue;
  public
    property Name: String read FName write FName;
    property Value: TValue read FValue write FValue;
    constructor Create(aName: String; aValue : TValue); overload;
  end;

  TRowElementItems = class(TList<TRowElementItem>)
  public
    function GetValueByName(aName : String): String;
    destructor Destroy; override;
  end;

  TRowItem = class
  private
    FRowElementItems: TRowElementItems;
  public
    constructor Create(aRowElementItems : TRowElementItems); overload;
    destructor Destroy; override;
    property RowElementItems: TRowElementItems read FRowElementItems write FRowElementItems;
  end;

  TSACREDListView = class(TAppearanceListView)
  private
    FListItems: TList<TRowItem>;
    FTemlate : ITemplateElement;
    FCountPiceLoad: Integer;
    FDelayLoadPice: Integer;
    FBeginLoadPeace : Boolean;
    FFirstItemPeace : Integer;
    FStopLoad : Boolean;
    FTask: ITask;
    FSearchBox : TSearchBox;
    FScrollBar : TScrollBar;
    FOnSearchEnter: TSearchEnter;
    FSearchVisible: Boolean;
    FOldSearchKeyUp : TKeyEvent;
    procedure AddNewItem(Sender: TObject; const Item: TRowItem; Action: System.Generics.Collections.TCollectionNotification);
    procedure SetSearchVisible(const Value: Boolean);
  protected
    procedure DoUpdatingItemView(const AListItem: TListItem; var AHandled: Boolean); override;
    procedure FindBaseItems; virtual;
    procedure OnSearchKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState); virtual;
    procedure OnSearchFilter(Sender: TObject; const AFilter: string; const AValue: string; var Accept: Boolean); virtual;
  public
    constructor Create(aOwner : TComponent; aTemlate : ITemplateElement); overload;
    destructor Destroy; override;
    property ListItems: TList<TRowItem> read FListItems write FListItems;
    procedure LoadPeace;
    procedure StopLoadPeace;
    procedure StopLoadPeaceOnClose;
    procedure Clear;
  published
    property SearchVisible: Boolean read FSearchVisible write SetSearchVisible;
    property OnSearchEnter: TSearchEnter read FOnSearchEnter write FOnSearchEnter;
    /// <summary>
    ///    Количество кусков для подгрузки за один такт.
    /// </summary>
    property CountPiceLoad: Integer read FCountPiceLoad write FCountPiceLoad;
    /// <summary>
    ///   Тайме отложенной загрузки кусков, через какое вермя будет подгружен следующий кусок данный, для разблокировки интерфейса
    /// </summary>
    property DelayLoadPice: Integer read FDelayLoadPice write FDelayLoadPice;

  end;

implementation

uses System.StrUtils, FMX.Dialogs, FMX.Forms;

const
  ITEM_INDEX_FIELD_NAME : String = 'Item_Index_Reference_Object';

{ TMyListView }

procedure TSACREDListView.AddNewItem;
begin
  Self.BeginUpdate;
  try
    case Action of
      System.Generics.Collections.TCollectionNotification.cnAdded:
        begin
//          LoadPeace;
        end;
      System.Generics.Collections.TCollectionNotification.cnRemoved: ;
      System.Generics.Collections.TCollectionNotification.cnExtracted: ;
    end;
  finally
    Self.EndUpdate;
  end;
end;

procedure TSACREDListView.Clear;
begin
  StopLoadPeace;
  FFirstItemPeace := 0;
  FListItems.Clear;
  Self.BeginUpdate;
  Self.Items.Clear;
  Self.EndUpdate;
end;

constructor TSACREDListView.Create(aOwner: TComponent; aTemlate : ITemplateElement);
var
  FSearchText: string;
begin
  inherited Create(aOwner);
  FFirstItemPeace := 0;
  FDelayLoadPice := 500;
  FCountPiceLoad := 1;
  FListItems := TList<TRowItem>.Create;
  FListItems.OnNotify := AddNewItem;

  FTemlate := aTemlate;

  Self.ItemAppearance.ItemAppearance   := 'TCustomizeItemObjects';
  Self.ItemAppearance.HeaderAppearance := 'TCustomizeItemObjects';
  Self.ItemAppearance.FooterAppearance := 'TCustomizeItemObjects';

  Self.TransparentItems      := True;
  Self.TransparentSeparators := True;
  Self.TransparentHeaders    := True;
  Self.SetColorHeader(TAlphaColorRec.Null);
  Self.SetColorBackground(TAlphaColorRec.Null);

  Self.ShowScrollBar := True;
//  FListView.SetColorHeader(TAlphaColorRec.Null);

//  case TOSVersion.Platform of
//    TOSVersion.TPlatform.pfiOS     : Self.ShowScrollBar := False;
//    TOSVersion.TPlatform.pfWindows : Self.ShowScrollBar := False;
//    TOSVersion.TPlatform.pfAndroid : Self.ShowScrollBar := False;
//    TOSVersion.TPlatform.pfMacOS   : Self.ShowScrollBar := False;
//  end;

  Self.ItemSpaces.Left := 2;
  Self.ItemSpaces.Right := 2;
  Self.ItemSpaces.Top := 1;
  Self.ItemSpaces.Bottom := 4;

  FindBaseItems;
  if FSearchBox <> nil then
  begin
    FSearchBox.OnKeyUp := Self.OnSearchKeyUp;
    FSearchBox.StyleLookup := 'SearchBoxTransparent';
    FSearchText := FSearchBox.Text;
    if FSearchText <> '' then
    begin
      FSearchBox.Text := '';
    end;
  end;
//  Self.EnableTouchAnimation(False);

end;

destructor TSACREDListView.Destroy;
var
  i: Integer;
  oItem: TRowItem;
begin
  if Assigned(FListItems) then
  begin
    for i := 0 to FListItems.Count-1 do
    begin
      oItem := FListItems.Items[i];
      FreeAndNil(oItem);
    end;
    FreeAndNil(FListItems);
  end;
  inherited;
end;

procedure TSACREDListView.DoUpdatingItemView(const AListItem: TListItem; var AHandled: Boolean);
var
  i: Integer;
  oItemList : TListViewItem;
  oMaxHeigth : Single;
  oMaxHeigthTemp: Single;
begin
  inherited;
  AListItem.BeginUpdate;
  oItemList := TListViewItem(AListItem);

  oItemList.Objects.Clear;
  if FTemlate <> nil then
  begin
    FTemlate.TemplateIncomes(oItemList);
  end;

  oMaxHeigth := 0;

  for i := 0 to oItemList.Objects.Count-1 do
  begin
    if (oItemList.Objects[i] is TBaseItem) then
    begin
      if TBaseItem(oItemList.Objects[i]).AutoHeigth then
      begin
        TBaseItem(oItemList.Objects[i]).CalcHeigth(Self.Width, Self.ItemSpaces.Top);
      end;

      if TBaseItem(oItemList.Objects[i]).ChainItem <> nil then
      begin
        TBaseItem(oItemList.Objects[i]).Paddings.Top := TBaseItem(oItemList.Objects[i]).ChainItem.Paddings.Top + TBaseItem(oItemList.Objects[i]).ChainItem.Height;
      end;

      oMaxHeigthTemp := TBaseItem(oItemList.Objects[i]).ApplyStyle;
      if oMaxHeigthTemp > oMaxHeigth then
      begin
        oMaxHeigth := oMaxHeigthTemp;
      end;
    end;
  end;

  for i := 0 to oItemList.Objects.Count-1 do
  begin
    if (oItemList.Objects[i] is TBaseItem) then
    begin
      oMaxHeigthTemp := TBaseItem(oItemList.Objects[i]).CalcMaxHeigthAlign(oMaxHeigth, Self.ItemSpaces);
      if oMaxHeigthTemp > oMaxHeigth then
      begin
        oMaxHeigth := oMaxHeigthTemp;
      end;
    end;
  end;

  for i := 0 to oItemList.Objects.Count-1 do
  begin
    if (oItemList.Objects[i] is TBaseItem) then
    begin
      TBaseItem(oItemList.Objects[i]).CorrectAlign(oMaxHeigth, Self.ItemSpaces);
    end;
  end;

  oItemList.Height := Round(oMaxHeigth+Self.ItemSpaces.Bottom);
  AListItem.EndUpdate;
//  AHandled := True;
//  Invalidate;
end;

procedure TSACREDListView.FindBaseItems;
var
  Child : TControl;
begin
  for Child in Self.Controls do
  begin
    if Child is TSearchBox then
    begin
      FSearchBox := TSearchBox(Child);
    end;
    if Child is TScrollBar then
    begin
      FScrollBar := TScrollBar(Child);
    end;
  end;
end;

procedure TSACREDListView.LoadPeace;
var
  oItem: TListViewItem;
begin
  if (Not FBeginLoadPeace) and (FFirstItemPeace < FListItems.Count) then
  begin
    FBeginLoadPeace := True;
    FTask := TTask.Run(
      procedure
      var
        iTempDelay : Integer;
      begin
        iTempDelay := FDelayLoadPice;
        while FFirstItemPeace <> FListItems.Count do
        begin
          TThread.Synchronize(
            TThread.CurrentThread,
            procedure
            var
                i, y: Integer;
                iTemp : Integer;
                iTempCount: Integer;
                sText : String;
            begin
              iTempCount := FCountPiceLoad;
              if FFirstItemPeace + iTempCount  > FListItems.Count then
              begin
                iTempCount := FListItems.Count - FFirstItemPeace;
              end;

              iTemp := FFirstItemPeace;
              if FStopLoad then
              begin
                Exit;
              end;

              for i := iTemp to FFirstItemPeace+iTempCount-1 do
              begin
                oItem := Self.Items.Add;
                for y := 0 to FListItems.Items[i].RowElementItems.Count-1 do
                begin
                  oItem.Data[FListItems.Items[i].RowElementItems.Items[y].Name] := FListItems.Items[i].RowElementItems.Items[y].Value;
                end;
                oItem.Data[ITEM_INDEX_FIELD_NAME] := i;
                oItem.Adapter.ResetView(oItem);
                Inc(FFirstItemPeace);
              end;
              if (FSearchBox <> nil) and (FSearchBox.Text <> '') then
              begin
                sText := FSearchBox.Text;
                FSearchBox.Text := '';
                FSearchBox.Text := sText;
                FSearchBox.SelStart := Length(FSearchBox.Text);
              end;
            end
          );
          if FFirstItemPeace <> FListItems.Count then
          begin
            Sleep(iTempDelay);
          end;
          if FStopLoad then
          begin
            Break;
          end;
        end;
        //TThread.Synchronize(nil, procedure begin ShowMessage('DONE LOAD: '+FListItems.Count.ToString()+' element') end);
        FBeginLoadPeace := False;
      end
    );
  end;
end;

procedure TSACREDListView.OnSearchFilter(Sender: TObject; const AFilter, AValue: string; var Accept: Boolean);
var
  Lower: string;
begin
  { DONE -oSACRED : Перетянуто из системных для дальнейшего контроля и ещё чего. }
  Lower := AFilter.Trim.ToLower;
  Accept := Lower.IsEmpty or AValue.ToLower.Contains(Lower);
end;

procedure TSACREDListView.OnSearchKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
var
  sText: string;
begin
  if Sender is TSearchBox then
  begin
    if Key = 13 then
    begin
      Key := 0;
      sText := TSearchBox(Sender).Text;
      if Assigned(OnSearchEnter) then
      begin
        OnSearchEnter(Sender, sText);
      end;
    end;
  end;
  if Assigned(FOldSearchKeyUp) then
  begin
    FOldSearchKeyUp(Sender, Key, KeyChar, Shift);
  end;
end;

procedure TSACREDListView.SetSearchVisible(const Value: Boolean);
begin
  if FSearchVisible <> Value then
  begin
    FSearchVisible := Value;
    TAppearanceListView(Self).SearchVisible := Value;
    FindBaseItems;
    if FSearchBox <> nil then
    begin
      FOldSearchKeyUp := FSearchBox.OnKeyUp;
      FSearchBox.OnKeyUp := Self.OnSearchKeyUp;
      FSearchBox.OnFilter := Self.OnSearchFilter;
      FSearchBox.StyleLookup := 'SearchBoxTransparent';
      FSearchBox.Text := '';
    end;
  end;
end;

procedure TSACREDListView.StopLoadPeace;
begin
  if Assigned(FTask) then
  begin
    FStopLoad := True;
    TTask.WaitForAll([FTask]);
    FStopLoad := False;
    FTask := nil;
  end;
end;

procedure TSACREDListView.StopLoadPeaceOnClose;
begin
  if Assigned(FTask) then
  begin
    FStopLoad := True;
    while FBeginLoadPeace do
    begin
      Sleep(10);
      Application.ProcessMessages;
    end;
    FStopLoad := False;
    FTask := nil;
  end;
end;

{ TRowElementItems }

destructor TRowElementItems.Destroy;
var
  i: Integer;
  oItem: TRowElementItem;
begin
  for i := 0 to Self.Count-1 do
  begin
    oItem := Self.Items[i];
    FreeAndNil(oItem);
  end;
  inherited;
end;

function TRowElementItems.GetValueByName(aName: String): String;
begin

end;

{ TRowItem }

constructor TRowItem.Create(aRowElementItems: TRowElementItems);
begin
  FRowElementItems := aRowElementItems
end;

destructor TRowItem.Destroy;
begin
  FreeAndNil(FRowElementItems);
  inherited;
end;

{ TRowElementItem }

constructor TRowElementItem.Create(aName: String; aValue: TValue);
begin
  inherited Create;
  FName := aName;
  FValue := aValue;
end;

end.
