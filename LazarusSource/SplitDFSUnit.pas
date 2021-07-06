unit SplitDFSUnit;

{
Copyright (C) 2018-2021 Gerald Holdsworth gerald@hollypops.co.uk

This source is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public Licence as published by the Free
Software Foundation; either version 3 of the Licence, or (at your option)
any later version.

This code is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public Licence for more
details.

A copy of the GNU General Public Licence is available on the World Wide Web
at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
to the Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
Boston, MA 02110-1335, USA.
}

{$mode objfpc}{$H+}

interface

uses
 Classes,SysUtils,Forms,Controls,Graphics,Dialogs,ComCtrls,EditBtn,Buttons,
 StdCtrls, ExtCtrls, Interfaces;

type

 { TSplitDFSForm }

 TSplitDFSForm = class(TForm)
  CancelButton: TBitBtn;
  CancelButton1: TBitBtn;
  DFSPages: TPageControl;
  CombinePanel: TPanel;
  OKBtnBack: TPanel;
  OKBtnBack1: TPanel;
  sbConfirmSplit: TBitBtn;
  sbConfirmCombine: TBitBtn;
  SplitPanel: TPanel;
  SplitSourceGroupBox: TGroupBox;
  SplitDestGroupBox0: TGroupBox;
  SplitDestGroupBox2: TGroupBox;
  CombDestGroupBox: TGroupBox;
  CombSource0GroupBox: TGroupBox;
  CombSource2GroupBox: TGroupBox;
  Buttons: TImageList;
  lbDestSSD2: TLabel;
  lbSourceSSD0: TLabel;
  lbSourceSSD2: TLabel;
  lbSourceDSD: TLabel;
  lbDestSSD0: TLabel;
  lbDestDSD: TLabel;
  OpenDialog: TOpenDialog;
  SaveDialog: TSaveDialog;
  sbLoadSourceDSD: TSpeedButton;
  sbSaveDestDSD: TSpeedButton;
  sbSaveDestSSD0: TSpeedButton;
  sbSaveDestSSD2: TSpeedButton;
  sbLoadSourceSSD0: TSpeedButton;
  sbLoadSourceSSD2: TSpeedButton;
  split: TTabSheet;
  combine: TTabSheet;
  procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
  function GetAbsAddr(address: Cardinal;side: Byte): Cardinal;
  procedure FormShow(Sender: TObject);
  procedure sbCancelClick(Sender: TObject);
  procedure sbConfirmCombineClick(Sender: TObject);
  procedure sbConfirmSplitClick(Sender: TObject);
  procedure sbLoadSourceSSD0Click(Sender: TObject);
  procedure sbSaveDestDSDClick(Sender: TObject);
  procedure sbSaveDestSSD0Click(Sender: TObject);
  procedure sbLoadSourceDSDClick(Sender: TObject);
  function IsImageValid(filename: String;dsd: Boolean): Boolean;
 private

 public

 end;

var
 SplitDFSForm: TSplitDFSForm;

implementation

{$R *.lfm}

{ TSplitDFSForm }

{------------------------------------------------------------------------------}
//Convert an address and side into a offset into the image
{------------------------------------------------------------------------------}
function TSplitDFSForm.GetAbsAddr(address: Cardinal;side: Byte): Cardinal;
var
 sector,
 offset : Cardinal;
begin
 //Taken directly from the DiscImage class
 sector:=address DIV $100; //Sectors are $100 in size, and we need to know the sector
 offset:=address MOD $100; //Offset within the sector
 //Annoyingly, it is the tracks which are interleaved, not the sectors.
 //On Acorn DFS discs, there are 10 sectors per track
 Result:=(((sector MOD 10)+(20*(sector DIV 10))+(10*side))*$100)+offset;
end;

{------------------------------------------------------------------------------}
//User has drop a file on the form
{------------------------------------------------------------------------------}
procedure TSplitDFSForm.FormDropFiles(Sender: TObject;
 const FileNames: array of String);
begin
 //If the active page is the splitter, then open it there
 if DFSPages.ActivePage=split then
 begin
  //Is it a double sided DFS?
  if IsImageValid(Filenames[0],True) then
  begin
   //Set the source filename
   lbSourceDSD.Caption:=FileNames[0];
   //And the destination filenames
   lbDestSSD0.Caption:=LeftStr(lbSourceDSD.Caption,Length(lbSourceDSD.Caption)-4)
                      +'-DFSSide0.ssd';
   lbDestSSD2.Caption:=LeftStr(lbSourceDSD.Caption,Length(lbSourceDSD.Caption)-4)
                      +'-DFSSide2.ssd';
  end;
  //Enable/Disable the confirm button
  sbConfirmSplit.Enabled:=(lbSourceDSD.Caption<>'')and
                          (lbDestSSD0.Caption<>'')and
                          (lbDestSSD2.Caption<>'');
 end;
 //If the active page is the combiner, then open it there
 if DFSPages.ActivePage=combine then
 begin
  //Is it a single sided DFS?
  if IsImageValid(Filenames[0],False) then
   //Have we already got one in the first side?
   if lbSourceSSD0.Caption='' then //No
   begin
    lbSourceSSD0.Caption:=FileNames[0]; //Update the labels
    //Is there a second?
    if Length(FileNames)>1 then
     //Is it a single sided DFS?
     if IsImageValid(Filenames[1],False) then
      lbSourceSSD2.Caption:=FileNames[1];
   end
   else //If first slot is already taken, put it in the second slot
    lbSourceSSD2.Caption:=FileNames[0]; //Update the labels
  //Enable/Disable the confirm button
  sbConfirmCombine.Enabled:=(lbDestDSD.Caption<>'')and
                            (lbSourceSSD0.Caption<>'')and
                            (lbSourceSSD2.Caption<>'');
 end;
end;

{------------------------------------------------------------------------------}
//Open a source DSD to split
{------------------------------------------------------------------------------}
procedure TSplitDFSForm.sbLoadSourceDSDClick(Sender: TObject);
begin
 //Set up the open dialogue
 OpenDialog.Filename:='';
 OpenDialog.Filter:='Double Sided DFS|*.dsd';
 OpenDialog.DefaultExt:='dsd';
 //Show the dialogue box
 If(OpenDialog.Execute)and(IsImageValid(OpenDialog.Filename,True)) then
 begin
  //Set the source filename
  lbSourceDSD.Caption:=OpenDialog.Filename;
  //And the destination filenames
  lbDestSSD0.Caption:=LeftStr(lbSourceDSD.Caption,Length(lbSourceDSD.Caption)-4)
                     +'-DFSSide0.ssd';
  lbDestSSD2.Caption:=LeftStr(lbSourceDSD.Caption,Length(lbSourceDSD.Caption)-4)
                     +'-DFSSide2.ssd';
 end;
 //Enable/Disable the confirm button
 sbConfirmSplit.Enabled:=(lbSourceDSD.Caption<>'')and
                         (lbDestSSD0.Caption<>'')and
                         (lbDestSSD2.Caption<>'');
end;

{------------------------------------------------------------------------------}
//Select a destination SSD for split
{------------------------------------------------------------------------------}
procedure TSplitDFSForm.sbSaveDestSSD0Click(Sender: TObject);
var
 side: Byte;
begin
 side:=0;
 //Work out which side
 if (Sender=sbSaveDestSSD0) then side:=0;
 if (Sender=sbSaveDestSSD2) then side:=2;
 //Set the save dialogue filename
 if side=0 then SaveDialog.Filename:=lbDestSSD0.Caption;
 if side=2 then SaveDialog.Filename:=lbDestSSD2.Caption;
 //And set up the rest of the dialogue
 SaveDialog.Filter:='Single Sided DFS|*.ssd';
 SaveDialog.DefaultExt:='ssd';
 //Show the dialogue
 if SaveDialog.Execute then
 begin
  //Show the filename in the label
  if side=0 then lbDestSSD0.Caption:=SaveDialog.Filename;
  if side=2 then lbDestSSD2.Caption:=SaveDialog.Filename;
 end;
 //Enable/Disable the confirm button
 sbConfirmSplit.Enabled:=(lbSourceDSD.Caption<>'')and
                         (lbDestSSD0.Caption<>'')and
                         (lbDestSSD2.Caption<>'');
end;

{------------------------------------------------------------------------------}
//Form is being shown
{------------------------------------------------------------------------------}
procedure TSplitDFSForm.FormShow(Sender: TObject);
begin
 //Clear all the labels
 lbSourceDSD.Caption     :='';
 lbDestSSD0.Caption      :='';
 lbDestSSD2.Caption      :='';
 lbSourceSSD0.Caption    :='';
 lbSourceSSD2.Caption    :='';
 lbDestDSD.Caption       :='';
 //Set the active page
 DFSPages.ActivePage     :=split;
 //And disable the confirm buttons
 sbConfirmSplit.Enabled  :=False;
 sbConfirmCombine.Enabled:=False;
end;

{------------------------------------------------------------------------------}
//Cancel clicked
{------------------------------------------------------------------------------}
procedure TSplitDFSForm.sbCancelClick(Sender: TObject);
begin
 Close;
end;

{------------------------------------------------------------------------------}
//Confirm clicked on combine
{------------------------------------------------------------------------------}
procedure TSplitDFSForm.sbConfirmCombineClick(Sender: TObject);
var
 sc        : array[0..1] of TFileStream;
 dst       : TFileStream;
 buffer    : array of Byte;
 address,
 i         : Cardinal;
 sidesize  : array[0..1] of Cardinal;
 side      : Byte;
begin
 //Set up the buffer
 SetLength(buffer,$A00);
 try
  //Open the three streams (one destination and two sources)
  dst:=TFileStream.Create(lbDestDSD.Caption,fmCreate or fmShareDenyNone);
  sc[0]:=TFileStream.Create(lbSourceSSD0.Caption,fmOpenRead OR fmShareDenyNone);
  sc[1]:=TFileStream.Create(lbSourceSSD2.Caption,fmOpenRead OR fmShareDenyNone);
  //Read each side and output
  for side:=0 to 1 do
  begin
   //How big is the side?
   sc[side].Position:=$106;
   i:=sc[side].Read(buffer[0],2);
   sidesize[side]:=(buffer[1]+(buffer[0]AND$3)*$100)*$100;
   //Read the side, in 10 sector chunks
   address:=$0;
   while address<sidesize[side] do
   begin
    //Clear the buffer
    for i:=0 to Length(buffer)-1 do buffer[i]:=0;
    //Read from the source
    //We make sure we don't read over the end
    //We'll still write all of buffer out, which is why we cleared it
    if address<sc[side].Size then
    begin
     //Position within the file
     sc[side].Position:=address;
     //And read
     i:=sc[side].Read(buffer[0],Length(buffer));
    end;
    //Write to the destination
    dst.Position:=GetAbsAddr(address,side);
    dst.Write(buffer[0],Length(buffer));
    //Move onto the next block
    inc(address,Length(buffer));
   end;
  end;
  //Close the three streams
  dst.Free;
  sc[0].Free;
  sc[1].Free;
  //All OK, so close with OK
  ModalResult:=mrOK;
 except
  //An error occurred, so feedback an abort
  ModalResult:=mrAbort;
 end;
end;

{------------------------------------------------------------------------------}
//Confirm clicked on Split
{------------------------------------------------------------------------------}
procedure TSplitDFSForm.sbConfirmSplitClick(Sender: TObject);
var
 src       : TFileStream;
 ds        : array[0..1] of TFileStream;
 buffer    : array of Byte;
 address,
 i         : Cardinal;
 sidesize  : array[0..1] of Cardinal;
 side      : Byte;
begin
 //Set up the buffer
 SetLength(buffer,$A00);
 try
  //Open the three streams (one source and two destinations)
  src:=TFileStream.Create(lbSourceDSD.Caption,fmOpenRead OR fmShareDenyNone);
  ds[0]:=TFileStream.Create(lbDestSSD0.Caption,fmCreate or fmShareDenyNone);
  ds[1]:=TFileStream.Create(lbDestSSD2.Caption,fmCreate or fmShareDenyNone);
  //Read each side and output
  for side:=0 to 1 do
  begin
   //How big is the side?
   src.Position:=GetAbsAddr($106,side);
   i:=src.Read(buffer[0],2);
   sidesize[side]:=(buffer[1]+(buffer[0]AND$3)*$100)*$100;
   //Read the side, in 10 sector chunks
   address:=$0;
   while address<sidesize[side] do
   begin
    //Clear the buffer
    for i:=0 to Length(buffer)-1 do buffer[i]:=0;
    //Read from the source
    //We make sure we don't read over the end
    //We'll still write all of buffer out, which is why we cleared it
    if GetAbsAddr(address,side)<src.Size then
    begin
     //Set the position within the file
     src.Position:=GetAbsAddr(address,side);
     //And read
     i:=src.Read(buffer[0],Length(buffer));
    end;
    //Write to the destination
    ds[side].Position:=address;
    ds[side].Write(buffer[0],Length(buffer));
    //And move the pointer on
    inc(address,Length(buffer));
   end;
  end;
  //Close the three streams
  src.Free;
  ds[0].Free;
  ds[1].Free;
  //All OK, so close with OK
  ModalResult:=mrOK;
 except
  //An error occurred, so feedback an abort
  ModalResult:=mrAbort;
 end;
end;

{------------------------------------------------------------------------------}
//Load a source SSD to combine
{------------------------------------------------------------------------------}
procedure TSplitDFSForm.sbLoadSourceSSD0Click(Sender: TObject);
var
 side: Byte;
begin
 side:=0;
 //Work out which side
 if (Sender=sbLoadSourceSSD0) then side:=0;
 if (Sender=sbLoadSourceSSD2) then side:=2;
 //Setup the dialogue box
 OpenDialog.Filename:='';
 OpenDialog.Filter:='Single Sided DFS|*.ssd';
 OpenDialog.DefaultExt:='ssd';
 //Show the dialogue box
 if(OpenDialog.Execute)and(IsImageValid(OpenDialog.Filename,False)) then
 begin
  //Update the label
  if side=0 then lbSourceSSD0.Caption:=OpenDialog.Filename;
  if side=2 then lbSourceSSD2.Caption:=OpenDialog.Filename;
 end;
 //Enable/Disable the confirm button
 sbConfirmCombine.Enabled:=(lbDestDSD.Caption<>'')and
                           (lbSourceSSD0.Caption<>'')and
                           (lbSourceSSD2.Caption<>'');
end;

{------------------------------------------------------------------------------}
//Save a destination DSD to combine
{------------------------------------------------------------------------------}
procedure TSplitDFSForm.sbSaveDestDSDClick(Sender: TObject);
begin
 //Set up the diaglogue box
 SaveDialog.Filename:=LeftStr(lbSourceSSD0.Caption,Length(lbSourceSSD0.Caption)-4)
                     +'.dsd';
 SaveDialog.Filter:='Double Sided DFS|*.dsd';
 SaveDialog.DefaultExt:='dsd';
 //Show it
 If SaveDialog.Execute then //Update the label
  lbDestDSD.Caption:=SaveDialog.Filename;
 //Enable/Disable the confirm button
 sbConfirmCombine.Enabled:=(lbDestDSD.Caption<>'')and
                           (lbSourceSSD0.Caption<>'')and
                           (lbSourceSSD2.Caption<>'');
end;

{------------------------------------------------------------------------------}
//Confirm if a supplied image is valid or not
{------------------------------------------------------------------------------}
function TSplitDFSForm.IsImageValid(filename: String;dsd: Boolean): Boolean;
var
 c,i,
 FFormat: Byte;
 t0,t1  : Integer;
 chk,dbl: Boolean;
 sec    : Cardinal;
 F      : TFileStream;
 buffer : array of Byte;
 function ReadByte(offset: Cardinal): Byte;
 begin
  Result:=buffer[offset];
 end;
 function Read16b(offset: Cardinal): Word;
 begin
  Result:=buffer[offset]+buffer[offset+1]<<8;
 end;
begin
 //Read the file in
 F:=TFileStream.Create(filename,fmOpenRead OR fmShareDenyNone);
 SetLength(buffer,F.Size);
 F.Read(buffer[0],F.Size);
 F.Free;
 FFormat:=$F;
 dbl:=True;
 //Is there actually any data?
 if Length(buffer)>0 then
 begin
  chk:=True;
  //Offset 0x0001 should have 9 bytes >31
  c:=0;
  for i:=0 to 8 do
   if(ReadByte($0001+i)>31)or(ReadByte($0001+i)=0)then inc(c);
  if c<>9 then chk:=False;
  //Offset 0x0100 should have 4 bytes >31
  c:=0;
  for i:=0 to 3 do
   if(ReadByte($0100+i)>31)or(ReadByte($0100+i)=0)then inc(c);
  if c<>4 then chk:=False;
  //Offset 0x0105 should have bits 0,1 and 2 clear (i.e. divisible by 8)
  if(ReadByte($0105)AND$7)<>0 then chk:=False;
  //Offset 0x0106 should have bits 2,3,6 and 7 clear
  if(ReadByte($0106)AND$CC)<>0 then chk:=False;
  //Above checks have passed
  if chk then
  begin
   dbl:=True; //Double sided flag
   //Check the entire first two sectors - if they are all zero assume ssd
   c:=0;
   for i:=0 to $FE do if ReadByte($0A00+i)=0 then inc(c);
   if(c=$FF)and(ReadByte($0AFF)=0)then dbl:=False;
   if dbl then
   begin
    for i:=0 to $FE do if ReadByte($B00+i)=0 then inc(c);
    if(c=$FF)and(ReadByte($0BFF)=0)then dbl:=False;
   end;
   //Offset 0x0A01 should have 9 bytes >31
   c:=0;
   for i:=0 to 8 do
    if(ReadByte($0A01+i)>31)or(ReadByte($0A01+i)=0)then inc(c);
   if c<>9 then dbl:=False;
   //Offset 0x0B00 should have 4 bytes >31
   c:=0;
   for i:=0 to 3 do
    if(ReadByte($0B00+i)>31)or(ReadByte($0B00+i)=0)then inc(c);
   if c<>4 then dbl:=False;
   //Offset 0x0B05 should have bits 0,1 and 2 clear
   if(ReadByte($0B05)AND$7)<>0 then dbl:=False;
   //Offset 0x0B06 should have bits 2,3,6 and 7 clear
   if(ReadByte($0B06)AND$CC)<>0 then dbl:=False;
   //Number of sectors, side 0
   t0:=ReadByte($0107)+((ReadByte($0106)AND$3)<<8);
   //DS tests passed, get the number of sectors, side 1
   if dbl then
    t1:=ReadByte($0B07)+((ReadByte($0B06)AND$3)<<8)
   else
    t1:=t0;
   //Not a double sided
   if t1=0 then
   begin
    //So mark as so
    dbl:=False;
    //This needs to be set to something other that 0, otherwise it'll fail to
    //ID as a DFS. Actually, DFS does accept zero length disc sizes, but
    //everything we have checked so far is for zeros.
    t1:=t0;
   end;
   if dbl then
    FFormat:=1
   else
    FFormat:=0;
{   //Number of sectors should be >0
   if(t0=0)or(t1=0)then
   begin
    FFormat:=$F;
    chk:=False;
   end;}
   //Now we check the files. If the sector addresses are outside the disc, we fail
   if(chk)and(ReadByte($105)>>3>0)then //If there are any entries
   begin
    //Side 0
    if t0=0 then t0:=$320; //Assume 200K disc
    for i:=0 to (ReadByte($105)>>3)-1 do
    begin
     //Get the start sector
     sec:=(ReadByte($108+7+i*8)+((ReadByte($108+6+i*8)AND$3)<<8))<<8;
     //And add the length to it
     inc(sec,Read16b($108+4+i*8)+((ReadByte($108+6+i*8)AND$30)<<12));
     //If the end of the file is over the end of the disc, fail it
     if sec>t0<<8 then chk:=False;
    end;
    //Side 2
    if dbl then
    begin
     if t1=0 then t1:=$320; //Assume 200K disc
     for i:=0 to (ReadByte($B05)>>3)-1 do
     begin
      //Get the start sector
      sec:=(ReadByte($B08+7+i*8)+((ReadByte($B08+6+i*8)AND$3)<<8))<<8;
      //And add the length to it
      inc(sec,Read16b($B08+4+i*8)+((ReadByte($B08+6+i*8)AND$30)<<12));
      //If the end of the file is over the end of the disc, fail it
      if sec>t1<<8 then chk:=False;
     end;
    end;
    //If checks have failed, then reset the format
    if not chk then FFormat:=$F;
   end;
  end;
  //Test for Watford DFS - we'll only test one side.
  if chk then
  begin
   //Offset 0x0200 should have 8 bytes of 0xAA
   c:=0;
   for i:=0 to 7 do
    if ReadByte($0200+i)=$AA then inc(c);
   //Offset 0x0300 should have 4 bytes of 0x00
   for i:=0 to 3 do
    if ReadByte($0300+i)=$00 then inc(c);
   //Disc size should match also
   if(c=12)and(Read16b($306)=Read16b($106))then
    inc(FFormat,2);
  end;
 end;
 Result:=(FFormat<>$F)AND(dbl=dsd);
end;

end.
