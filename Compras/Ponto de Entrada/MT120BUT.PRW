#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

User Function MA120BUT() 

	Local aButtons := {}    

aadd(aButtons,{ 'Conhecimento' ,{||  MsDocument('SC7',SC7->(RecNo()), 4) },'Conhecimento','Conhecimento' } )
aadd(aButtons,{ 'Duplicar Linha' ,{||  U_C7DUPLIN() },'Duplicar linha' } )

Return (aButtons )



User Function C7DUPLIN()

Local nPosCcus    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CC"})
Local nPosCco     := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CO"})
Local nPosItem	  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_ITEMCTA"})
Local nPosClvl	  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CLVL"})

If MsgYesNo("Deseja copiar linha ?")

     aTemp := aClone(aCols)
     aAdd(aCols, aTemp[n])
     aCols[Len(aCols),1] := StrZero(Len(aCols),4)
     
EndIf
//Limpa campos obrigatórios
if nPosCcus > 0
	acols[Len(aCols)][nPosCcus] := ""
ENDIF
if nPosCco > 0
	acols[Len(aCols)][nPosCco] := ""
ENDIF
if nPosItem > 0
	acols[Len(aCols)][nPosItem] := ""
ENDIF
if nPosClvl > 0
	acols[Len(aCols)][nPosClvl] := ""
ENDIF

return()


