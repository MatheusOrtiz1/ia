#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "totvs.CH"
/*
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao: Programa para importar lan?amentos mensais da folha RGB     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function IMPZ29()

Private cPerg       := "IMPZ29  "
Private oLeTxt		:= ""

VALIDPERG()

@ 300,1 TO 480,480 DIALOG oLeTxt TITLE OemToAnsi("Leitura de Arquivo Texto")
@ 02,10 TO 070,200
@ 10,018 Say " Este programa ira ler o conteudo de um arquivo texto, conforme"
@ 18,018 Say " os parametros definidos pelo usuario, com os registros do arquivo"
@ 26,018 Say " Z29 - CONTROLE FATURAMENTO           "

@ 70,128 BMPBUTTON TYPE 01 ACTION OkLeTxt6()
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)

Activate Dialog oLeTxt Centered

Return
/*/
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
/*/
Static Function OkLeTxt6
Private cTitulo1	:= "Selecione o arquivo"
Private cExtens		:= ""
Private	cFileOpen 	:= ""
Private nHdl    	:= fOpen(mv_par01,68)
Private cEOL    	:= "CHR(13)+CHR(10)"

cFileOpen := cGetFile(cExtens,cTitulo1,,,.F.)

If !File(cFileOpen)
	MsgAlert("Arquivo texto: "+cFileOpen+" não localizado","IMPZ29")
	Return
Endif
	
	Processa({|| RunCont() },"Processando...")

Return

/*/
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa Importa                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunCont

Local cBuffer 			:= ""
Local ni,cID
Private aDados			:= {}
Private aDadosZ29		:= {}
Private aNEncontrados	:= {}
Private Linha

FT_FUSE(cFileOpen) //ABRIR
FT_FGOTOP() //PONTO NO TOPO

ProcRegua(FT_FLASTREC()) //QTOS REGISTROS LER

While !FT_FEOF() //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
	IncProc()
	
	If FT_FLastRec() == 1
		FT_FSkip()
	endif
	
	IncProc() // Capturar dados
	cBuffer := FT_FREADLN() //LENDO LINHA
	
	
	//Tratativa para retirar caracteres especiais
	cBuffer := STRTRAN(cBuffer,'""',"")
	cBuffer := STRTRAN(cBuffer,"ï","")
	cBuffer	:= STRTRAN(cBuffer,"¿","")
	cBuffer := STRTRAN(cBuffer,"»","")
	cBuffer := STRTRAN(cBuffer,"-","")
	cBuffer := STRTRAN(cBuffer,"?","")
	cBuffer := STRTRAN(cBuffer,"!","")
	cBuffer := STRTRAN(cBuffer,"^","")
	cBuffer := STRTRAN(cBuffer,"é","e")
	cBuffer := STRTRAN(cBuffer,"õ","o")
	cBuffer := STRTRAN(cBuffer,"Ã","A")
	cBuffer := STRTRAN(cBuffer,"©","o")
	cBuffer := STRTRAN(cBuffer,"ã","a")
	cBuffer := STRTRAN(cBuffer,"ã","a")
    cBuffer := UPPER(cBuffer)
	cMsg := "Código: " + cBuffer
	//MsgInfo(cMsg)
	
	aDados:= StrTokArr2(cBuffer, ";",.T.)
	
	AADD(aDadosZ29,{ dData:=(CTOD(aDados[01])), aDados[02], aDados[03], aDados[04], aDados[05],;
                     aDados[06], aDados[07], aDados[08], aDados[09], aDados[10],;
                     CVALTOCHAR(aDados[11]), CVALTOCHAR(aDados[12]), CVALTOCHAR(aDados[13]), CVALTOCHAR(aDados[14]), CVALTOCHAR(aDados[15]),;
                     CVALTOCHAR(aDados[16]), aDados[17], aDados[18], CVALTOCHAR(aDados[19]), CVALTOCHAR(aDados[20]),;
                     CVALTOCHAR(aDados[21]), aDados[22], aDados[23], CVALTOCHAR(aDados[24])})
		
	FT_FSKIP() //próximo registro no arquivo txt
EndDo

FT_FUSE() //fecha o arquivo txt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ³
//³ cao anterior.                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ni := 1 To Len(aDadosZ29)

	cID := getSX8Num("Z29", "Z29_ID")
        confirmSX8()
    DbSelectArea("Z29")                   
    IF RECLOCK("Z29",.T.)		
        Z29->Z29_FILIAL  := xFilial("Z29")                                                                                    
        Z29->Z29_ID      := cID
        Z29->Z29_DATA    := aDadosZ29[ni,01]
        Z29->Z29_HORA    := aDadosZ29[ni,02]
        Z29->Z29_STATUS  := '2'
        Z29->Z29_OS      := aDadosZ29[ni,03]
        Z29->Z29_NMTRSG  := aDadosZ29[ni,04]
        Z29->Z29_MOTORI  := aDadosZ29[ni,05]                                                                           
        Z29->Z29_PLACA   := aDadosZ29[ni,06]                                                                          
        Z29->Z29_TRANSP  := aDadosZ29[ni,07] 
        Z29->Z29_ORIGEM  := aDadosZ29[ni,08]
        Z29->Z29_TIPO    := aDadosZ29[ni,09]                                                                                                             
        Z29->Z29_SBTIPO  := aDadosZ29[ni,10]
        Z29->Z29_VOLUME  := VAL( aDadosZ29[ni,11])                                                                     
        Z29->Z29_VOLUM1  := VAL( aDadosZ29[ni,12] )                                                                    
        Z29->Z29_PH      := VAL( aDadosZ29[ni,13] )                                                                   
        Z29->Z29_TEMPER  := VAL( substr(aDadosZ29[ni,14],1,4) )                                                                  
        Z29->Z29_SOLIDO  := aDadosZ29[ni,15]                                                                
        Z29->Z29_DQO     := VAL( aDadosZ29[ni,16] )                                                                
        Z29->Z29_OBSERV  := aDadosZ29[ni,17]                                                                     
        Z29->Z29_MESFAT  := aDadosZ29[ni,18]                                                                     
        Z29->Z29_PRECOM  := VAL( aDadosZ29[ni,19] )                                                                    
        Z29->Z29_VLRTOT  := VAL( aDadosZ29[ni,20] )                                                                   
        Z29->Z29_FRETE   := VAL( aDadosZ29[ni,21] )                                                                  
        Z29->Z29_TOTAL   := VAL( aDadosZ29[ni,22] )                                                                 
        Z29->Z29_NFISCA  := aDadosZ29[ni,23]                                                                     
        Z29->Z29_FTPARA  := aDadosZ29[ni,24]                                                                     
        MSUNLOCK()
	ENDIF
Next nI

MsgInfo("Processo finalizada")

Return

//VALIDA PERGUNTA
STATIC FUNCTION VALIDPERG()
**************************
LOCAL _AREA := GETAREA()
LOCAL AREGS := {}
Local J,I

DBSELECTAREA("SX1")
DBSETORDER(1)
CPERG 	:= PADR(CPERG,10)

// GRUPO/ORDEM/PERGUNTA/VARIAVEL/TIPO/TAMANHO/DECIMAL/PRESEL/GSC/VALID/VAR01/DEF01/CNT01/VAR02/DEF02/CNT02/VAR03/DEF03/CNT03/VAR04/DEF04/CNT04/VAR05/DEF05/CNT05/X1_F3
AADD(AREGS,{CPERG,"01","LOCAL ?  "," ?"," ?","MV_CHA","C",60,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","DIR"})
FOR I:=1 TO LEN(AREGS)
	IF !DBSEEK(CPERG+AREGS[I,2])
		RECLOCK("SX1",.T.)
		FOR J:=1 TO FCOUNT()
			IF J <= LEN(AREGS[I])
				FIELDPUT(J,AREGS[I,J])
			ENDIF
		NEXT
		MSUNLOCK()
	ENDIF
NEXT
RESTAREA(_AREA)
RETURN

