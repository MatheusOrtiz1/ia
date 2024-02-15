#INCLUDE 'ap5mail.ch'
#INCLUDE 'tbiconn.ch'
#INCLUDE 'rwmake.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'fileio.ch'

// IMPORTACAO DE LANCAMENTOS, ARQUIVO .CSV NO FORMATO
//COD_CONTA;DATA(YYYYMMDD);VALOR_CREDITO;VALOR_DEBITO;

User Function IMPCT2BI()
Local i,j
Private oLeTxt
Private aDados
Private aCod		 := {}
Private cPerg  	     := "IMPCT2BI  "
Private cEOL    	 := "CHR(13)+CHR(10)"

Private nPEmp  	 := 1
Private nPCdReg	 := 3
Private nPDsReg	 := 5
Private nPMun	 := 6

IF !cEmpAnt # "31/32/33/34/35"
	alert("Somente pra empresas 31/32/33/34/35")
	return
endif

AREGS := {}
AADD(AREGS,{CPERG,"01","ARQUIVO A IMPORTAR ?","","","MV_CH1","C",80,0,0,"G","!Vazio().or.(mv_par01:=cGetFile('Arquivos |*.*','',,,,))","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(AREGS,{CPERG,"02","LOTE ?","","","MV_CH1","C",6,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(AREGS,{CPERG,"03","DOC ?","","","MV_CH1","C",9,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
DBSELECTAREA("SX1")
DBSETORDER(1)
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

IF !PERGUNTE(CPERG,.T.)
	RETURN()
ENDIF

@ 200,1 TO 380,380 DIALOG oLeTxt TITLE OemToAnsi("Leitura de Arquivo Texto")
@ 02,10 TO 080,190
@ 10,018 Say " Este programa ira ler o conteudo de um arquivo texto, conforme"
@ 18,018 Say " os parametros definidos pelo usuario, com os registros do arquivo"
@ 26,018 Say "                                                            "

@ 70,128 BMPBUTTON TYPE 01 ACTION Processa({||OkLeTxt() })
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)

Activate Dialog oLeTxt Centered

Return


static function OkLeTxt
Local i
Private nTamFile, nTamLin, cBuffer, nBtLidos
Private nHdl    := fOpen(mv_par01,68)
If Empty(cEOL)
	cEOL := CHR(13)+CHR(10)
Else
	cEOL := Trim(cEOL)
Endif

If nHdl == -1
	MsgAlert("O arquivo de nome "+mv_par01+" nao pode ser aberto! Verifique os parametros.","Atencao!")
	Return
Endif

If File(MV_PAR01)
	FT_FUse(MV_PAR01)
	FT_FGotop()
	cLinha := FT_FReadLn()
	FT_FSkip()//PULA O CABECALHO
	cLinha := ""
	aDados := {}
	aLinha := {}
	_CONT := 0
	
	procregua(FT_FLASTREC())
	While !FT_FEOF() //.and. _cont<301
		incproc("Lendo Arquivo...")
		_CONT++
		cLinha := FT_FReadLn()
		cLinha := strtran(cLinha,"-","")
		cLinha := strtran(cLinha,"/","")
		cLinha := strtran(cLinha,"%","")
		cLinha := strtran(cLinha,".","")
		cLinha := strtran(cLinha,",",".")
		_auxIni := 1
		_auxFim := 1
		while _auxFim<=len(cLinha)
			if substr(cLinha,_auxFim,1) == ";"
				aadd(aLinha,alltrim(substr(cLinha,_auxIni,_auxFim-_auxIni)))
				_auxFim++
				_auxIni := _auxFim
			else
				_auxFim++
			endif
		enddo
		aadd(aLinha,substr(cLinha,_auxIni,_auxFim-_auxIni))
		aadd(aDados,aLinha)
		aLinha := {}
		FT_FSkip()
		//	FT_FUse()
	EndDo
	FT_FUse()
else
	MSGINFO("Favor verificar os parametros.","Arquivo não encontrado")
endif

_erro := alltrim(strtran(mv_par01,".",""))+".ERRO"
MEMOWRIT(_erro, "")
IF LEN(aDados)>0
	
	for i:=1 to len(aDados)
		LrECLOCK := .f.
		dbselectarea("SZA")
		dbsetorder(1)//ZA_FILIAL+ZA_OUCONTA+ZA_CONTA
		if dbseek(xFilial()+padr(alltrim(aDados[i,1]),20))
			dbselectarea("CT2")
			if val(aDados[i,4])>0                                 
				RECLOCK("CT2",.T.)
				CT2->CT2_FILIAL := xFilial("CT2")				
				CT2->CT2_CREDIT := SZA->ZA_CONTA
				CT2->CT2_VALOR  := val(aDados[i,4])
				CT2->CT2_ORIGEM := "IMPORT"
				CT2->CT2_HIST   := STRZERO(I,3)+"IMPORTADO EM "+DTOC(DATE())+" POR "+usrfullname(__cuserid)
				CT2->CT2_DATA   := stod(aDados[i,2])
				CT2->CT2_LOTE   := MV_PAR02
				CT2->CT2_DOC    := MV_PAR03
				CT2->CT2_LINHA  := STRZERO(I,3)
				CT2->CT2_DC     := "2"				
				MSUNLOCK()
				lReclock := .t.
			endif
			if val(aDados[i,3])>0              
				if lReclock                           				
					reclock("CT2",.F.)
					CT2->CT2_DC     := "3"
					CT2->CT2_VALOR  := CT2->CT2_VALOR-val(aDados[i,3])
				else
					RECLOCK("CT2",.T.)                  
					CT2->CT2_DC     := "1" 
					CT2->CT2_FILIAL := xFilial("CT2")
					CT2->CT2_DEBITO := SZA->ZA_CONTA     
					CT2->CT2_ORIGEM := "IMPORT"
					CT2->CT2_HIST   := STRZERO(I,3)+"IMPORTADO EM "+DTOC(DATE())+" POR "+usrfullname(__cuserid)
					CT2->CT2_DATA   := stod(aDados[i,2])
					CT2->CT2_LOTE   := MV_PAR02
					CT2->CT2_DOC    := MV_PAR03
					CT2->CT2_LINHA  := STRZERO(I,3)					
					CT2->CT2_VALOR  := val(aDados[i,3])					
				endif
				MSUNLOCK()
			endif
		else
			if (nHandle := fopen(_erro,FO_READWRITE)) >= 0
				nFinal := fSeek(nHandle,0,2)
				fSeek(nHandle,nFinal)
				FWRITE(nHandle, "CONTA "+padr(alltrim(aDados[i,1]),20)+" NAO EXISTE NA SZA. REGISTRO "+cValToChar(i)+chr(10)+chr(13))
				fClose(nHandle)
			endif		
		endif
	next
	alert("Importados "+cValToChar(len(aDados))+" registros.")
endif
return
