{
DXF to LISA(MECWAY)  Convert DXF 3DFACE to LISA file.
Copyright (C) 2021  Paulo C. Ormonde

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
}

unit clisa;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Dialogs, ComCtrls, Buttons, Math;

type
   Point3D = record
           x: real; // x coordinate of point
           y: real; // y coordinate of point
           z: real; // z coordinate of point
   end;

   type
   faces = record
             gp:string;    // group
             p1,p2,p3,p4:Point3D;   // four points
             na,nb,nc,nd:integer;   // node numbers
   end;


   var

       face: array of faces;   // 3dface matrix
       node: array of Point3D;
       gp: array of string;    // array groups
       ngp: integer;           // number of groups
       nfaces:integer;         // number of faces
       nnodes:integer;         // number of nodes
       filedxf:string;         // DXF file
       lisafile:string;        // LISA file
       fileface:string;        // Face file
       pclic:tpoint;           // temp point
       panmode:boolean;        // pan command
       wp: integer;            // 0:ZX 1:XY 2:YZ
       sf: real;               // scale factor
       pos:integer;            // process position



        Function number(S:String):String;
        procedure readdxf ( dlg:TOpenDialog; pbr:TProgressBar);  // Read DXF file
        procedure salvarlisa (pbs:TProgressBar) ;                  // Save LISA file
        procedure ion (pbi:TProgressBar) ;                       // Incidence of nodes

implementation


//------------------------------------------------------------------------------
//  Function Number  - Enter float number
//------------------------------------------------------------------------------
Function number(S:String):String;
var  i : integer;
  Begin
  Result:='';
     for i:= 1 to Length(S) do begin

         if S[i] in ['0'..'9','.','-'] then begin   // apenas numeros
         Result:=Result + S[i];
         end else begin Result := Result;
         end;
     end;
end;


//------------------------------------------------------------------------------
//  READ DXF FILE
//------------------------------------------------------------------------------
procedure readdxf ( dlg:TOpenDialog ; pbr:TProgressBar);
var
  F: Textfile;   //arquivo de texto
  i,j,k:integer;
  txt:string;
  tcode:string;
  ft: faces;

begin

nfaces:=0;
DecimalSeparator:='.';
  if dlg.Execute then begin      // Open dialog
  filedxf:= dlg.FileName;
  end;

  if filedxf <> '' then begin    // global variable
    AssignFile(F, filedxf);
    Reset(F);
    while not EOF(F) do begin
    Readln(F,txt);
      if uppercase(txt) = '3DFACE' then begin
        nfaces:= nfaces + 1;
      end;
    end;
  CloseFile(F);
  end;

    pbr.max:=nfaces*6;


   if nfaces > 0  then begin
   SetLength(face,nfaces+1); // set matrix length
       AssignFile(F, filedxf);
         Reset(F);
         j:=0;
           while not EOF(F) do begin
             Readln(F,txt);
               if trim(uppercase(txt)) = '3DFACE' then begin
                j:= j + 1;

                pbr.Repaint; pbr.Repaint;  pbr.Repaint;
                pbr.position:=j;

                tcode:=trim(uppercase(txt));
                     while tcode <> '8' do begin    // layer description
                     Readln(F,txt);
                     tcode:=trim(uppercase(txt));
                     if tcode = '8' then begin
                      Readln(F,txt);
                      ft.gp:= trim(txt);
                     end;
                     end;

                     tcode:=trim(uppercase(txt));
                     while tcode <> '10' do begin    // corners
                     Readln(F,txt);
                     tcode:=trim(uppercase(txt));
                     if tcode = '10' then begin
                      Readln(F,txt);                 // 10
                      ft.p1.x:= strtoFloat (txt);
                      Readln(F,txt);  Readln(F,txt); // 20
                      ft.p1.y:= strtoFloat (txt);
                      Readln(F,txt);  Readln(F,txt); // 30
                      ft.p1.z:= strtoFloat (txt);

                      Readln(F,txt); Readln(F,txt);  // 11
                      ft.p2.x:= strtoFloat (txt);
                      Readln(F,txt);  Readln(F,txt); // 21
                      ft.p2.y:= strtoFloat (txt);
                      Readln(F,txt);  Readln(F,txt); // 31
                      ft.p2.z:= strtoFloat (txt);

                      Readln(F,txt); Readln(F,txt);  // 12
                      ft.p3.x:= strtoFloat (txt);
                      Readln(F,txt);  Readln(F,txt); // 22
                      ft.p3.y:= strtoFloat (txt);
                      Readln(F,txt);  Readln(F,txt); // 32
                      ft.p3.z:= strtoFloat (txt);

                      Readln(F,txt); Readln(F,txt);  // 13
                      ft.p4.x:= strtoFloat (txt);
                      Readln(F,txt);  Readln(F,txt); // 23
                      ft.p4.y:= strtoFloat (txt);
                      Readln(F,txt);  Readln(F,txt); // 33
                      ft.p4.z:= strtoFloat (txt);
                     end;
                     end;
            face[j]:= ft;
      end;
    end;
  pos:=nfaces;
  CloseFile(F);
   end;
end;



//------------------------------------------------------------------------------
// ion - Incidence of nodes
//------------------------------------------------------------------------------
   procedure ion (pbi:TProgressBar);
   var
     tnode: array of Point3D;
     tgp: array of string;
     i,j:integer;
     addnode:boolean;
     addgp:boolean;
   begin

    nnodes:= 1;
    ngp:=1;
    SetLength(node,nnodes+1);
    SetLength(gp,ngp+1);
    SetLength(tnode,(nfaces*4)+1);
    SetLength(tgp,nfaces+1);

    for i:= 1 to nfaces do begin   // read nodes of each face
     tnode[(i*4)-3]:=face[i].p1;
     tnode[(i*4)-2]:=face[i].p2;
     tnode[(i*4)-1]:=face[i].p3;
     tnode[i*4]:=face[i].p4;
     tgp[i]:=face[i].gp;
    end;

    pbi.max:=(nfaces*6);
    pbi.Position:=pos;


    // define groups
    gp[1]:=tgp[1];
    for i:= 1 to nfaces do begin
      addgp:=true;
        for j:=1 to ngp do begin
          if gp[j] = tgp[i] then begin
           addgp:=false;
          end;
        end;
        if addgp = true then begin
          ngp:= ngp+1;
          SetLength(gp,ngp+1);
          gp[ngp]:=tgp[i];
        end;
    end;


   // define list of nodes
    node[1]:=tnode[1];
    for i:= 1 to nfaces*4 do begin
    addnode:=true;
      for j:=1 to nnodes do begin
       if (node[j].x=tnode[i].x) and (node[j].y=tnode[i].y) and (node[j].z=tnode[i].z) then begin
        addnode:=false;
       end;
      end;
      if addnode = true then begin
       nnodes:=nnodes+1;
       SetLength(node,nnodes+1);
       node[nnodes]:=tnode[i];
      end;
      pbi.position:=pbi.position + i;
    end;

   for i:= 1 to nfaces do begin  // Incidence of nodes
       for j:= 1 to nnodes do begin
         if (node[j].x=face[i].p1.x) and (node[j].y=face[i].p1.y) and (node[j].z=face[i].p1.z) then begin
         face[i].na:=j;
         end;
         if (node[j].x=face[i].p2.x) and (node[j].y=face[i].p2.y) and (node[j].z=face[i].p2.z) then begin
         face[i].nb:=j;
         end;
         if (node[j].x=face[i].p3.x) and (node[j].y=face[i].p3.y) and (node[j].z=face[i].p3.z) then begin
         face[i].nc:=j;
         end;
         if (node[j].x=face[i].p4.x) and (node[j].y=face[i].p4.y) and (node[j].z=face[i].p4.z) then begin
         face[i].nd:=j;
         end;
       end;
       pbi.position:= pbi.position + i;
   end;

   end;


//------------------------------------------------------------------------------
//    CONVERTER GEOMETRIA 3DFACE PARA LISA 8.0
//------------------------------------------------------------------------------
procedure salvarlisa (pbs:TProgressBar) ;
var
  F: Textfile;
  i,j,n:integer;

  begin

  if lisafile <> '' then begin
    AssignFile(F, lisafile);
    Rewrite(F);

      writeln(F, '<liml8>');
      writeln(F, '<analysis type="S30" />');

      pbs.Max:= nnodes + nfaces + 2;
      pbs.position:=0;

    // Nodes ---> nid
      for i:= 1 to nnodes do begin

      case wp of

      0:begin
      writeln(F,'<node nid="' + Inttostr(i) +
                '" x="' + formatfloat('0.000000',node[i].x * sf) +
                '" y="' + formatfloat('0.000000',node[i].z * sf) +
                '" z="' + formatfloat('0.000000',node[i].y * sf) + '" />');
        end;

     1:begin
      writeln(F,'<node nid="' + Inttostr(i) +
                '" x="' + formatfloat('0.000000',node[i].x * sf) +
                '" y="' + formatfloat('0.000000',node[i].y * sf) +
                '" z="' + formatfloat('0.000000',node[i].z * sf) + '" />');
     end;

     2:begin
      writeln(F,'<node nid="' + Inttostr(i) +
                '" x="' + formatfloat('0.000000',node[i].z * sf) +
                '" y="' + formatfloat('0.000000',node[i].y * sf) +
                '" z="' + formatfloat('0.000000',node[i].x * sf) + '" />');
     end;
        end;
            pbs.position:= pbs.position+i;
      end;


    // 3DFaces  ---> elset
    for j:= 1 to ngp do begin
    writeln(F, '<elset name="' + gp[j] + '" color="-6710887">' );
    for i:=1 to nfaces do  begin
     if face[i].gp = gp[j] then begin
    writeln(F, '<elem eid="' + IntTostr(i) + '" shape="quad4" nodes="' + inttostr(face[i].na) + ' '
                                                                       + inttostr(face[i].nb) + ' '
                                                                       + inttostr(face[i].nc) + ' '
                                                                       + inttostr(face[i].nd) + '" />');
    pbs.position:= pbs.position+i;
     end;
    end;

    writeln(F, '</elset>');

    end;
  writeln(F, '</liml8>');  // end of the file
  CloseFile(F);

  pbs.position:= pbs.max;
  end;
  end;


end.

