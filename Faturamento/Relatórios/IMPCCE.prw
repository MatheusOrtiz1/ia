#INCLUDE "rwmake.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
#include "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMPCCE    บAutor  ณEverton Forti       บ Data ณ  19/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressใo da CC-e                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ???????????                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function IMPCCE()   

Local nCONNSPED := U_MICONNSPED()

//TCUnLink(nCONNSPED)

	SetPrvt("TAMANHO,WNREL,ARETURN,NLASTKEY,NTIPO,NTIPOA,CSTRING")
	SetPrvt("LEND,TITULO,TITULO2,CDESC1,CDESC2,CDESC3,CPERG")
	SetPrvt("NOMEPROG,M_PAG,aResult,aLinhas,vQuery")

	Tamanho  := "P"
	wnRel    := 'IMPCCE'
	aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",0 }
	nLastKey := 0
	nTipo    := 18
	cString  :="SRA"
	lEnd     :=.F.
	cDesc1   := "Este relatorio ira imprimir a CARTA DE CORRE??O ELETRONICA (CC-e)"
	cDesc2   := ""
	cDesc3   := ""
	cPerg    := ""
	nomeprog := "IMPCCE"
	nLastKey := 0
	cabec1   := ""
	cabec2   := ""
	m_pag    := 01                 
	aResult  := {}                                 
	aLinhas  := {}                                
	vQuery   := "" 
    
	cperg    := "IMPCCE" 
	
	aHelp := {}
	AAdd( aHelp, 'Informe o n?mero da Nota Fiscal que     ' )
	AAdd( aHelp, 'deseja imprimir a Carta de Corre??o     ' )
	PutSX1( cPerg,"01","Numero da Nota Fiscal?","Numero da Nota Fiscal?","Numero da Nota Fiscal?","mv_ch1","C",TamSX3("F2_DOC")[1],0,1,"C","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp)
	
	aHelp := {}
	AAdd( aHelp, 'Informe a s้rie da Nota Fiscal que      ' )
	AAdd( aHelp, 'deseja imprimir a Carta de Corre??o     ' )
	PutSX1( cPerg,"02","S้rie da Nota Fiscal?","S้rie da Nota Fiscal?","S้rie da Nota Fiscal?","mv_ch2","C",TamSX3("F2_SERIE")[1],0,1,"C","","","","","mv_par02","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp)
	
	IF !Pergunte(cPerg,.T.)
		Return
	Endif                                                             
	titulo   := "CARTA DE CORREวรO ELETRONICA - CCe"

	Processa({|| Gera1276()},"Gera Dados para impressใo")  

Return             

static function NFEID(cID)
Local cRes                       
	                       
vQuery := " select out_str = substring( "
vQuery += " 	CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),  "
vQuery += " 	CHARINDEX('infNFe Id=', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+14, 44) "
vQuery += " 	from SPED050 INNER JOIN SPED001 ON SPED050.ID_ENT=SPED001.ID_ENT "
vQuery += " 	where NFE_ID = '"+cID+"' "
vQuery += " 	and SPED050.D_E_L_E_T_ <> '*' AND SPED001.D_E_L_E_T_ <> '*' AND SPED001.CNPJ='"+ALLTRIM(SM0->M0_CGC)+"'"
TCQUERY vQuery NEW ALIAS "TEMP1"
dbselectarea("TEMP1")
while !eof()
	cRes := TEMP1->OUT_STR
	DBSKIP()
enddo
TEMP1->(DBCLOSEAREA())
return cRes

STATIC FUNCTION DADOSCCE(cID)

Local nCONNSPED := 0   

aRes := {}
vQuery := " select "
vQuery += " versao = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),CHARINDEX('versao=', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+8, 4), "
vQuery += " id_lote = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),CHARINDEX('<idLote>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+8, 1), "
vQuery += " id_evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),CHARINDEX('<infEvento Id=', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+15, 54), "
vQuery += " orgao = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),CHARINDEX('<cOrgao>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+8, 2), "
vQuery += " ambiente = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),CHARINDEX('<tpAmb>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+7, 1), "
vQuery += " CNPJ = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),CHARINDEX('<CNPJ>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+6, 14), "
vQuery += " Chave_Acesso = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),CHARINDEX('<chNFe>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+7, 44), "
vQuery += " Data_Evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),CHARINDEX('<dhEvento>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+10, 10), "
vQuery += " Hora_Evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),CHARINDEX('<dhEvento>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+21, 8), "
vQuery += " Cod_Evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),	CHARINDEX('<tpEvento>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+10, 6), "
vQuery += " Seq_Evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),CHARINDEX('<nSeqEvento>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+12, 1), "
vQuery += " Versao_Evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), CHARINDEX('<verEvento>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+11, 3), "
vQuery += " Det_Evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),CHARINDEX('<detEvento versao=', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+19, 4), "
vQuery += " Desc_Evento = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),CHARINDEX('<descEvento>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+12, 17), "
vQuery += " Correcao = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))), CHARINDEX('<xCorrecao>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+11,CHARINDEX('</xCorrecao>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))-CHARINDEX('<xCorrecao>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))-11 ), "
vQuery += " Cond_Uso = substring(CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))),CHARINDEX('<xCondUso>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))+10,CHARINDEX('</xCondUso>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))- CHARINDEX('<xCondUso>', CONVERT(TEXT,CONVERT(VARCHAR(max),CONVERT(VARBINARY(max),XML_SIG))))-10 ) "
vQuery += " 	from SPED150 INNER JOIN SPED001 ON SPED150.ID_ENT=SPED001.ID_ENT "
vQuery += " 	where NFE_CHV = '"+cID+"' "
vQuery += " 	and SPED150.D_E_L_E_T_ <> '*' AND SPED001.D_E_L_E_T_ <> '*' AND SPED001.CNPJ='"+ALLTRIM(SM0->M0_CGC)+"'"
TCQUERY vQuery NEW ALIAS "TEMP"
dbselectarea("TEMP")
WHILE !EOF() 
	//       1            2             3               4           5              6          7                  8                 9                10                11               12                  13               14                16             17
	ARES := {TEMP->VERSAO,TEMP->ID_LOTE,TEMP->ID_EVENTO,TEMP->ORGAO,TEMP->AMBIENTE,TEMP->CNPJ,TEMP->CHAVE_ACESSO,TEMP->DATA_EVENTO,TEMP->HORA_EVENTO,TEMP->COD_EVENTO,TEMP->SEQ_EVENTO,TEMP->VERSAO_EVENTO,TEMP->DET_EVENTO,TEMP->DESC_EVENTO,TEMP->CORRECAO,TEMP->COND_USO}
	DBSKIP()
ENDDO

TCUnLink(nCONNSPED)

TEMP->(DBCLOSEAREA())

return aRes

Static Function Gera1276()
	Local aAreaTMP  := GetArea()
	Local cError   := ""
	Local cWarning := ""
	Local oXml := NIL
	Local vInd
	
	vNfeId := mv_par02+mv_par01

	vNfeChv := NFEID(vNfeID)
	                                  
	aResult := {}
	If !Empty(vNfeChv)
		aResult := dadoscce(vNfeChv)
	EndIf	
	nLin       := 10000
	nCol	   := 800
	nPage	   := 1
	nHeight    := 08
	lBold	   := .F.
	lUnderLine := .F.
	lPixel	   := .T.
	lPrint	   := .F.                
	//oFont	:= TFont():New( "Arial"             ,,_xsize,,_xnegrito,,,,, lUnderLine ) 
	oFtA07	:= TFont():New( "Arial"  ,,07     ,,.f.  ,,,,, .f.  )
	oFtA07N	:= TFont():New( "Arial"  ,,07     ,,.t.  ,,,,, .f.  )
	oFtA08	:= TFont():New( "Arial"  ,,08     ,,.f.  ,,,,, .f.  )
	oFtA08N	:= TFont():New( "Arial"  ,,08     ,,.t.  ,,,,, .f.  )
	oFtA09	:= TFont():New( "Arial"  ,,09     ,,.f.  ,,,,, .f.  )
	oFtA09N	:= TFont():New( "Arial"  ,,09     ,,.t.  ,,,,, .f.  )
	oFtA10	:= TFont():New( "Arial"  ,,10     ,,.f.  ,,,,, .f.  )
	oFtA10N	:= TFont():New( "Arial"  ,,10     ,,.t.  ,,,,, .f.  )
	oFtA12	:= TFont():New( "Arial"  ,,12     ,,.f.  ,,,,, .f.  )
	oFtA12N	:= TFont():New( "Arial"  ,,12     ,,.t.  ,,,,, .f.  )
	oFtA14	:= TFont():New( "Arial"  ,,14     ,,.f.  ,,,,, .f.  )
	oFtA14N	:= TFont():New( "Arial"  ,,14     ,,.t.  ,,,,, .f.  )


	//OPen		:= TPen():New(0,5,CLR_BLACK)
	//		oPrint:Box(0530,1900,0730,2300)
	//		oPrint:FillRect({0530,1900,0730,2300},oBrush)
	//		oPrint:Line(nLinha,740,nLinha+70,740)
	nLin := 3000
			
	lAdjustToLegacy := .F. 
	lDisableSetup  := .T.

	oPrn := FWMSPrinter():New("CARTA DE CORRECAO ELETRONICA - CCe", 6, lAdjustToLegacy, , lDisableSetup)			
	oPrn:LPDFASPNG := .F.	
	oPrn:SetResolution(72)
	oPrn:SetPortrait()
	oPrn:SetPaperSize(9)  // a4
	oPrn:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior 
	oPrn:cPathPDF := "C:\TEMP\"  // Caso seja utilizada impress?o em IMP_PDF		 
			
//	oPrn:= TMSPrinter():New() // Inicializa o Objeto de impressao
//	oPrn:SetLandscape()

	If nLin>480
		Cab977()
	Endif         

	oPrn:Say(nLin ,0210 ,"CARTA DE CORREวรO", 		oFta14N, 100 )                                  
	nlin+=40                        	

	oPrn:Say(nLin ,0120 ,"Versใo", 		oFta12, 100 )                                  
	nlin+=10                        	
	oPrn:Say(nLin ,0120 ,aResult[1], 	oFta12, 100 )                                  
	nlin+=20                        	
	 	
	oPrn:Say(nLin ,0010 ,"Ambiente", 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0120 ,"Id", 			oFta12, 100 )                                  
	oPrn:Say(nLin ,0420 ,"Orgใo", 		oFta12, 100 )                                  
	nlin+=10                        	
	oPrn:Say(nLin ,0010 ,iif(aResult[5]=="1","Produ็ใo","Homologa็ใo"), 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0120 ,aResult[3], 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0420 ,aResult[4], 	oFta12, 100 )                                  
	nlin+=20                        	
	
	oPrn:Say(nLin ,0010 ,"CNPJ", 			oFta12, 100 )                                  
	oPrn:Say(nLin ,0120 ,"Chave de Acesso",	oFta12, 100 )                                  
	oPrn:Say(nLin ,0420 ,"Data/Hora",		oFta12, 100 )                                  
	nlin+=10                        	
	oPrn:Say(nLin ,0010 ,aResult[6], 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0120 ,aResult[7], 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0420 ,aResult[8]+"-"+aResult[9], 	oFta12, 100 )                                  
	nlin+=20                        	

	oPrn:Say(nLin ,0010 ,"Cod. Evento",		oFta12, 100 )                                  
	oPrn:Say(nLin ,0120 ,"Seq. Evento",		oFta12, 100 )                                  
	oPrn:Say(nLin ,0420 ,"Versใo Evento",	oFta12, 100 )                                  
	nlin+=10                        	
	oPrn:Say(nLin ,0010 ,aResult[10], 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0120 ,aResult[11], 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0420 ,aResult[12], 	oFta12, 100 )                                  
	nlin+=20                        	
	
	oPrn:Say(nLin ,0010 ,"Serie NF",		oFta12, 100 )                                  
	oPrn:Say(nLin ,0120 ,"Numero NF",		oFta12, 100 )                                  
//	oPrn:Say(nLin ,0420 ,"Versใo Evento",	oFta12, 100 )                                  
	nlin+=10                        	
	oPrn:Say(nLin ,0010 ,MV_PAR02, 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0120 ,MV_PAR01, 	oFta12, 100 )                                  
//	oPrn:Say(nLin ,0420 ,aResult[12], 	oFta12, 100 )                                  
	nlin+=40                        		

	oPrn:Say(nLin ,0010 ,"INFORMAวีES DA CARTA DE CORREวรO",		oFta12N, 100 )                                  
	nlin+=20	

	oPrn:Say(nLin ,0010 ,"Versใo",			oFta12, 100 )                                  
	oPrn:Say(nLin ,0210 ,"Descr. Evento",	oFta12, 100 )                                  
	nlin+=10                        	
	oPrn:Say(nLin ,0010 ,aResult[13], 	oFta12, 100 )                                  
	oPrn:Say(nLin ,0210 ,aResult[14], 	oFta12, 100 )                                  
	nlin+=40                        	
              
	oPrn:Say(nLin ,0010 ,"Texto da Carta de Corre็ใo",			oFta12, 100 )                                  
	nlin+=10                        	

	vTexto := u_FormatText(decodeutf8(aResult[15]), 100, aLinhas)
    For vInd := 1 to len(aLinhas)
		oPrn:Say(nLin ,0010 ,aLinhas[vInd, 1], 	oFta12, 100 )		
		nlin+=10                        	
	Next    	
	
	aLinhas := {}	
	nLin +=30

	oPrn:Say(nLin ,0010 ,"Condi็๕es de Uso da Carta de Corre็ใo",			oFta12, 100 )                                  
	nlin+=10                        	

	vTexto := u_FormatText(aResult[16], 100, aLinhas)
    For vInd := 1 to len(aLinhas)
		oPrn:Say(nLin ,0010 ,aLinhas[vInd, 1], 	oFta12, 100 )		
		nlin+=10                        	
	Next    	

	SetPgEject(.F.) // Funcao pra n?o ejetar pagina em branco 
	oPrn:Setup()   // para configurar impressora - comentar se quiser gerar o PDF direto.
//	oPrn:Preview() // Visualiza relatorio na tela     
	oPrn:Print() // Visualiza relatorio na tela
	Ms_Flush()             


Return .T.
	
//-------------------------------------------------------------------------------------------------
Static function Cab977()
	_cNomLogo := "LGRL"+cEmpAnt+cFilAnt+".BMP" //"APOLONOVA.BMP"
	_nLarg    := 100
	_nAlt     := 100
	If nlin<10000
		oPrn:EndPage()
		oPrn:StartPage()
	Endif                    
	nLin := 30
	oPrn:SayBitmap( nlin  , 0010 , _cNomLogo     , _nLarg , _nAlt )
	nLin += 5
	oPrn:Say( nLin+5, 0470 , "Data : " + Dtoc(dDataBase)   , oFtA07 , 100 )      
	nLin += 10
	oPrn:Say( nLin+5, 0470 , "Pagina : " + StrZero(npage,3)     , oFtA07 , 100 )
	nLin += 10
	
  	oPrn:Say( nLin+710 , 0005 , nomeprog            , oFtA07 , 100 )
	oPrn:Say( nLin+710 , 0470 ,"Hora : " + Time()   , oFtA07 , 100 )      
	oPrn:Say( nLin+720 , 0005 , "SIGA/V.P11"        , oFtA07 , 100 )

	npage++
	nLin := 90    
Return(.t.)

//----------------------------------------------------------------------------
User FUNCTION FormatText(cMemo, nLen)
//----------------------------------------------------------------------------
// Objetivo      : Formata linhas do campo memo                               *
// Observacao    :                                                            *
// Sintaxe       : FormatText(@cMemo, nLen)                                   *
// Parametros    : cMemo ----> texto memo a ser formatado                     *
//                 nLen  ----> tamanho de colunas por linha                   *
// Retorno       : array aLinhas - retorna o texto linha a linha              *
// Fun. chamadas : CalcSpaces()                                               *
// Arquivo fonte : Memo.prg                                                   *
// Arq. de dados : -                                                          *
// Veja tamb?m   : MemoWindow()                                               *
//----------------------------------------------------------------------------
LOCAL nLin, cLin, lInic, lFim, aWords:={}, cNovo:="", cWord, lContinua, nTotLin,nAux,vInd

   lInic:=.T.
   lFim:=.F.
   nTotLin:=MLCOUNT(cMemo, nLen)
   FOR nLin:=1 TO nTotLin

      cLin:=RTRIM(MEMOLINE(cMemo, nLen, nLin)) //recuperar

      IF EMPTY(cLin) //Uma linha em branco ->Considerar um par?grafo vazio
         IF lInic  //Inicio de paragrafo
           aWords:={}  //Limpar o vetor de palavras
           lInic:=.F.
         ELSE
            AADD(aWords, CHR(13)+CHR(10)) //Incluir quebra de linha
         ENDIF
         AADD(aWords, CHR(13)+CHR(10)) //Incluir quebra de linha
         lFim:=.T.
      ELSE
         IF lInic  //Inicio de paragrafo
            aWords:={} //Limpar o vetor de palavras
            //Incluir a primeira palavra com os espacos que a antecedem
            cWord:=""
            WHILE SUBSTR(cLin, 1, 1)==" "
               cWord+=" "
               cLin:=SUBSTR(cLin, 2)
            END
            IF(nNext:=AT(SPACE(1), cLin))<>0
               cWord+=SUBSTR(cLin, 1, nNext-1)
            ENDIF
            AADD(aWords, cWord)
            cLin:=SUBSTR(cLin, nNext+1)
            lInic:=.F.
         ENDIF
         //Retirar as demais palavras da linha
         WHILE(nNext:=AT(SPACE(1), cLin))<>0
            IF !EMPTY(cWord:=SUBSTR(cLin, 1, nNext-1))
               IF cWord=="," .AND. !EMPTY(aWords)
                  aWords[LEN(aWords)]+=cWord
               ELSE
                  AADD(aWords, cWord)
               ENDIF
            ENDIF
            cLin:=SUBSTR(cLin, nNext+1)
         END
         IF !EMPTY(cLin) //Incluir a ultima palavra
            IF cLin=="," .AND. !EMPTY(aWords)
               aWords[LEN(aWords)]+=cLin
            ELSE
               AADD(aWords, cLin)
            ENDIF
         ENDIF
         IF nLin==nTotLin  //Foi a ultima linha -> Finalizar o paragrafo
            lFim:=.T.
         ELSEIF RIGHT(cLin, 1)=="." //Considerar que o 'ponto' finaliza paragrafo
            AADD(aWords, CHR(13)+CHR(10))
            lFim:=.T.
         ENDIF
      ENDIF

      IF lFim
         IF LEN(aWords)>0
            nNext:=1
            nAuxLin:=1
            WHILE nAuxLin<=LEN(aWords)
               //Montar uma linha formatada
               lContinua:=.T.
               nTot:=0
               WHILE lContinua
                  nTot+=(IF(nTot=0, 0, 1)+LEN(aWords[nNext]))
                  IF nNext==LEN(aWords)
                     lContinua:=.F.
                  ELSEIF (nTot+1+LEN(aWords[nNext+1]))>=nLen
                     lContinua:=.F.
                  ELSE
                     nNext++
                  ENDIF
               END
               IF nNext==LEN(aWords)  //Ultima linha ->Nao formata
                  FOR nAux:=nAuxLin TO nNext
                     cNovo+=(IF(nAux==nAuxLin, "", " ")+aWords[nAux])
                  NEXT
               ELSE //Formatar
                  FOR nAux:=nAuxLin TO nNext
                     cNovo+=(CalcSpaces(nNext-nAuxLin, nLen-nTot-1, nAux-nAuxLin)+aWords[nAux])
                  NEXT
                  cNovo+=" "
               ENDIF
               nNext++
               nAuxLin:=nNext
            END
         ENDIF

         lFim:=.F.  //Indicar que o fim do paragrafo foi processado
         lInic:=.T. //Forcar inicio de paragrafo

      ENDIF

   NEXT

   //Retirar linhas em branco no final
   WHILE LEN(cNovo)>2 .AND. (RIGHT(cNovo, 2)==CHR(13)+CHR(10))
      cNovo:=LEFT(cNovo, LEN(cNovo)-2)
   END

	For vInd := 0 to (len(cNovo)/nLen)
		AADD(aLinhas, {Substr(cNovo, (vInd*nLen)+1, nLen) } )
	Next		

RETURN(cNovo)

//----------------------------------------------------------------------------
Static FUNCTION CalcSpaces(nQt, nTot, nPos)
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Objetivo      : Calcula espacos necessarios para completar a linha         *
// Observacao    :                                                            *
// Sintaxe       : CalcSpaces(nQt, nTot, nPos)                                *
// Parametros    : nQt  ---> quantidade de separacoes que devem existir       *
//                 nTot ---> total de caracteres em branco excedentes a serem *
//                           distribuidos                                     *
//                 nPos ---> a posicao de uma separacao em particular         *
//                           (comecando do zero)                              *
// Retorno       : a separacao ja pronta de posicao nPos                      *
// Fun. chamadas : -                                                          *
// Arquivo fonte : Memo.prg                                                   *
// Arq. de dados : -                                                          *
// Veja tamb?m   : MemoWindow()                                               *
//----------------------------------------------------------------------------
LOCAL cSpaces,; //Retorno de espacos
      nDist,;   //Total de espacos excedentes a distribuir em cada separacao
      nLim      //Ate que posicao devera conter o resto da divisao

   IF nPos==0
      cSpaces:=""
   ELSE
      nDist:=INT(nTot/nQt)
      nLim:=nTot-(nQt*nDist)
      cSpaces:=REPL(SPACE(1), 1+nDist+IF(nPos<=nLim, 1, 0))
   ENDIF

RETURN cSpaces

//----------------------------------------------------------------------------
STATIC FUNCTION Position(nMode, nRow, nCol, lEdicao)
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Objetivo      : Mostra linha e coluna na edicao do campo memo              *
// Observacao    :                                                            *
// Sintaxe       : Position(nMode, nRow, nCol, lEdicao)                       *
// Parametros    : nMode ---> Nome da funcao de controle da memoedit          *
//                 nRow  ---> Linha                                           *
//                 nCol  ---> Coluna                                          *
//                 lEdicao -> .T. p/ edicao .F. p/ consulta  de campo memo    *
// Retorno       : NIL                                                        *
// Fun. chamadas : FillString()                                               *
// Arquivo fonte : Memo.prg                                                   *
// Arq. de dados : -                                                          *
// Veja tamb?m   : MemoWindow()                                               *
//----------------------------------------------------------------------------
STATIC nPictRow, nPictCol

LOCAL cRow, cCol

IF lEdicao
   IF nMode==1
      nPictRow:=nRow
      nPictCol:=nCol
      FillString(nPictRow, nPictCol-5, " Lin    ")
      FillString(nPictRow, nPictCol+3, " Col    ")
      nRow:=0
      nCol:=0
   ENDIF
   FillString(nPictRow, nPictCol, PADR(ALLTRIM(STR(nRow)),3))
   FillString(nPictRow, nPictCol+8, PADR(ALLTRIM(STR(nCol)),3))
ENDIF

RETURN NIL
//----------------------------------------------------------------------------
STATIC FUNCTION FillString(nRow, nCol, cString)
//----------------------------------------------------------------------------*
// Objetivo      : Imprime uma string na tela sem mudar a cor de fundo        *
// Observacao    :                                                            *
// Sintaxe       : fillstring(a,b,c)                                          *
// Parametros    : nRow  ----> linha                                          *
//                 nCol  ----> coluna                                         *
//                 cString --> string                                         *
// Retorno       : NIL                                                        *
// Fun. chamadas : -                                                          *
// Arquivo fonte : Memo.prg                                                   *
// Arq. de dados : -                                                          *
// Veja tamb?m   : MemoWindow()                                               *
//----------------------------------------------------------------------------
LOCAL cArea, cNewArea, nK, nLen

nLen     := LEN(cString)
cArea    := SAVESCREEN(nRow, nCol, nRow, nCol+nLen-1)
cNewArea := ""
FOR nK := 1 TO nLen
   cNewArea += SUBSTR(cString, nK, 1)+SUBSTR(cArea, 2*nK, 1)
NEXT
RESTSCREEN(nRow, nCol, nRow, nCol+nLen-1, cNewArea)

RETURN NIL

/*               
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMICONNSPEDบAutor  ณRafael Parma        บ Data ณ  06/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo responsแvel por abrir conexใo com db/sevidor SPED/NFEบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Moinho Igua็u                                   บฑฑ   
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*---------------------------*
User Function MICONNSPED()
*---------------------------*
Local nCONNSPED := 0   
Local cDBSPED := AllTRIM(SuperGetMV("MV_MIDBSPD",,"MSSQL/TSS"))
Local cIPSPED := AllTRIM(SuperGetMV("MV_MIIPSPD",,"192.168.0.62"))
Local nPTSPED := SuperGetMV("MV_MIPTSPD",,7890) 
Private nCONNLOC := 0    
				
	TCConType("TCPIP")
	nCONNLOC := TCLink(cDBSPED, cIPSPED, nPTSPED) // NOME BCO / NOME ALIAS / IP SERVIDOR OU NOME SERVIDOR
	
	If nCONNLOC <= 0
		Alert("Falha na conexใo TOPCONN ("+cDBSPED+" - "+cIPSPED+") - ID-Erro: " + Alltrim(STR(nCONNLOC)) )
		TCUnLink(nCONNLOC)
	EndIf     

Return (nCONNLOC)