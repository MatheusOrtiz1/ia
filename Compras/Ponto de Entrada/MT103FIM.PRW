#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH "
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³MT103FIM  ºAutor  Everton Forti          Data ³  01/10/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE EXECUTADO NO FINAL DA NF ENTRADA                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/

USER FUNCTION MT103FIM()     
Local _I
Local cIntmax 			:= "N"
Local xGeratag			:= ""
LOCAL xEmp1 			:= SuperGetMV("MV_UFILMX",.F.,"")
Local nConfirma 		:= PARAMIXB[2]
Local xPar09 := ""
Private _aParametros 		:= {}
Private _ACOLS 			:= {}
Private lDEBUG			:= .F. //ajustar parametro na função seguinte tambem

 // Ponto de chamada ConexãoNF-e sempre como primeira instrução
    U_GTPE002()
	
IF FunName() == "MATA103" .AND. INCLUI .OR. l103Class

	IF cNumemp $ xEmp1 .AND. nConfirma == 1

		//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM                                                                                                     
		xD1ite  	:= ASCAN(AHEADER,{|X|X[2]=="D1_ITEM   "})
		xD1cod  	:= ASCAN(AHEADER,{|X|X[2]=="D1_COD    "})
		xD1qtd  	:= ASCAN(AHEADER,{|X|X[2]=="D1_QUANT  "})
		xD1loc  	:= ASCAN(AHEADER,{|X|X[2]=="D1_LOCAL  "})
		xD1dia  	:= ASCAN(AHEADER,{|X|X[2]=="D1_UDIASGA"})
		xD1sta  	:= ASCAN(AHEADER,{|X|X[2]=="D1_USTATUS"})
		xD1vun  	:= ASCAN(AHEADER,{|X|X[2]=="D1_VUNIT  "})
		xD1idg  	:= ASCAN(AHEADER,{|X|X[2]=="D1_UIDGARA"})
		xD1dtd  	:= ASCAN(AHEADER,{|X|X[2]=="D1_DTDIGIT"})
		xD1Tes  	:= ASCAN(AHEADER,{|X|X[2]=="D1_TES    "})
		
		FOR _I:=1 TO LEN(ACOLS) //FOR POR ITEM

			IF !ACOLS[_i,len(aHeader)+1]

				IF !ACOLS[_I,xD1Tes] == "011" //VERIFICA TES INT
					DBSELECTAREA("SF4")
					DBSETORDER(1)
					IF DBSEEK(xFILIAL("SF4")+ACOLS[_I,xD1Tes])
						IF SF4->F4_ESTOQUE == "N"
							LOOP
						endif
					ENDIF
				ENDIF

				DBSELECTAREA("SB1")
				DBSETORDER(1)
				IF DBSEEK(xFILIAL("SB1")+ACOLS[_I,xD1cod])
					cIntmax 	:= SB1->B1_UINTMAX
					xGeratag	:= SB1->B1_UGERTAG
				ENDIF

					IF cIntmax == "S" //.AND. xGeratag == "S"

						xPar01 := xFilial("SD1")
						xPar02 := SD1->D1_DOC
						xPar03 := SD1->D1_SERIE
						xPar04 := SD1->D1_FORNECE
						xPar05 := SD1->D1_LOJA
						xPar06 := ACOLS[_I,xD1ite] 
						xPar07 := ACOLS[_I,xD1cod] 	
						xPar08 := ACOLS[_I,xD1qtd] 
						xPar09 := ACOLS[_I,xD1loc] 
						xPar10 := ACOLS[_I,xD1dia] 
						xPar11 := ACOLS[_I,xD1sta] 
						xPar12 := SD1->D1_NUMSEQ 
						xPar13 := SD1->D1_CUSTO 
						xPar14 := ACOLS[_I,xD1vun] 
						xPar15 := ACOLS[_I,xD1idg] 
						xPar16 := ACOLS[_I,xD1dtd] 

						aadd( _aParametros,{cEmpant,xPar01,xPar02,xPar03,xPar04,xPar05,xPar06,xPar07,xPar08,xPar09,xPar10,xPar11,xPar12,xPar13,xPar14,xPar15,xPar16,SF1->F1_EMISSAO,SF1->F1_VALBRUT,RetCodUsr()})
					ENDIF
			ENDIF
		NEXT _I


			IF !EMPTY(_aParametros)

				PROCESSA({|| TEMPJOB(_aParametros)},"Aguarde!") 

				IF lDEBUG
					U_MT103PORC(_aParametros) //debug
				ELSE
				StartJob("U_MT103PORC()",GetEnvServer(),.F.,_aParametros)
				ENDIF

				MSGINFO("Suas TAGs já estão sendo geradas em segundo plano, assim que terminar você será avisado por e-mail!","MT103FIM")
			ENDIF

	ENDIF

			/*
			Verifica Retenção (SIGAGCT) e gera Título da Retenção Automaticamente
			Chamada Adriano Guedes  (GFORTI)  01/05/2023
		*/
		If nConfirma == 1
			U_CNS0001()

		EndIf
		
ENDIF

RETURN

USER FUNCTION MT103PORC(paramixb)

	Local xSeq,xTag,cLote:= "",cRetorno:="", cIntmax, xGeratag, xDescB1,  CLocdes, cUB_CCID, cZ16desc:=""
	local lOK 		:= .F.
	Local cTagG1	:=""
	Local _i,_x
	Local cTagOri
	Private xAsetnum
	Private cSigla := ""
	Private xPar00, xPar01, xPar02, xPar03, xPar04, xPar05, xPar06, xPar07, xPar08, xPar09, xPar10, xPar11, xPar12, xPar13, xPar14, xPar15, xPar16, xPar17, xPar18
	Private aAllTAgs := {}
	Private lDEBUG := .F.
	
	IF !lDEBUG
		PREPARE ENVIRONMENT EMPRESA paramixb[01,01]  FILIAL paramixb[01,02] //DEBUG COMENTAR
	ENDIF
   cSigla := SuperGetMV("MV_UTAGSG",.F.,"")
	conout(cSigla)
	FOR _I:=1 TO LEN(paramixb) //FOR POR ITEM

		xPar00	   := paramixb[_I,01] // Empresa     
		xPar01	   := paramixb[_I,02] //Filial       
		xPar02	   := paramixb[_I,03] //Documento    
		xPar03	   := paramixb[_I,04] //Serie        
		xPar04	   := paramixb[_I,05] //Fornece      
		xPar05	   := paramixb[_I,06] //Loja         
		xPar06	   := paramixb[_I,07] //Item         
		xPar07	   := paramixb[_I,08] //Codigo       
		xPar08	   := paramixb[_I,09] //Quantidade   
		xPar09	   := paramixb[_I,10] //Local        
		xPar10	   := paramixb[_I,11] //Dias Garantia
		xPar11	   := paramixb[_I,12] //Status       
		xPar12	   := paramixb[_I,13] //Numsqe       
		xPar13	   := paramixb[_I,14] //Custo        
		xPar14	   := paramixb[_I,15] //Vunit        
		xPar15	   := paramixb[_I,16] //ID Garantia  
		xPar16	   := paramixb[_I,17] //Data Digitação      
		xPar17	   := paramixb[_I,18] //Emissão      
		xPar18	   := paramixb[_I,19] //Valbrut      
		xPar19	   := paramixb[_I,20] //RetCodUsr()      
		xPar20	   := Time()

		xSeq  	:= "00000"

			DBSELECTAREA("SB1")
			DBSETORDER(1)
			IF DBSEEK(xFILIAL("SB1")+xPar07)
				cIntmax 	:= SB1->B1_UINTMAX
				xGeratag	:= SB1->B1_UGERTAG
				xDescB1 	:= SB1->B1_DESC
				cB1custD	:= SB1->B1_CUSTD 
				cUtippro	:= SB1->B1_UTIPPRO
				DBSELECTAREA("Z16")
				DBSETORDER(1)
				DBSEEK(xFILIAL("Z16")+cUtippro) 
				cZ16desc	:= Z16->Z16_DESCRI

				DBSELECTAREA("SB2")
				DBSETORDER(1)
				DBSEEK(xFilial("SB2") + xPar07 + xPar09)

				cB2cust		:= SB2->B2_CM1
				cB2saldo	:= SB2->B2_QATU

				DBSELECTAREA("NNR")
				DBSETORDER(1)
				DBSEEK(xFILIAL("NNR")+xPar09)
				cLote  		:= NNR->NNR_USIGLA+ "-"
				CLocdes		:= NNR->NNR_ULOCAT
				cUB_CCID	:= NNR->NNR_UCC
				//If NNR->NNR_UINT=="S"
					IF cIntmax == "S"

						FOR _X:=1 TO xPar08 //For quantidade para gerar as linhas

							IF xGeratag == "S"

								cTagOri := ""
								
								IF xPar11 $ "G/R"
									xSeq  	:= "000"
									cTagOri := ""					
									//----------------------------------------------------------//
									//-----------------SEQUENCIA GARANTIA-----------------------//
									//----------------------------------------------------------//
									DBSELECTAREA("Z23")
									DBSETORDER(6)
									IF DBSEEK(xFilial("Z23")+ALLTRIM(xPar15)+xPar07+SPACE(51)+"S")
										dbselectarea("Z12")	
										dbsetorder(6)
										IF DBSEEK(xFilial("Z12")+xPar07+Z23->Z23_TAGORI) //Codigo+TAGORI
											cTagOri := ALLTRIM(Z23->Z23_TAGORI)
											cTagGar := ALLTRIM(Z23->Z23_TAGORI)
											cTamanho:= LEN(cTagGar)
											cTamanho := cTamanho-1
											cTagGar := SUBSTR(cTagGar,1,cTamanho)
											cXsigla := Z12->Z12_LOTECT
											//left(cTagGar,len(alltrim(cTagGar))-1)								
											cRetorno := Z12->Z12_TAG3
											cSigla   := SUBSTR(Z12->Z12_TAG1,1,2)
											while !Z12->(eof()) .AND. xFilial("Z12")+xPar07+Z23->Z23_TAGORI == Z12->Z12_FILIAL+Z12->Z12_COD+Z12->Z12_TAGORI
												xSeq  := SOMA1(xSeq)
												Z12->(DBSKIP())
											enddo
											
											xAsetnum := Z12->Z12_TAG4+ALLTRIM(xPar11)+xSeq
										ELSE
											ConOut("PRODUTO X ID GARANTIA X TAG NAO ENCONTRADA")
											RETURN()
										endif

										//----------------------------------------------------------//
										//-------------------GRAVA RETORNO GARANTIA-----------------//
										//----------------------------------------------------------//	

											IF RECLOCK("Z23",.F.)
												Z23->Z23_DTRET  := DATE()
												Z23->Z23_DOC 	:= xPar02//SF1->F1_DOC
												Z23->Z23_SERIE  := xPar03//SF1->F1_SERIE
												Z23->Z23_CLIFOR	:= xPar04//SF1->F1_FORNECE
												Z23->Z23_LOJA	:= xPar05//SF1->F1_LOJA	
												Z23->Z23_TAGORI := cTagOri
												IF xPar11 $ "G"
													Z23->Z23_NEWTAG := cTagGar+"G"+xSeq
													cTagG1 := cTagGar+"G"+xSeq
												ELSEIF xPar11 $ "R"
													Z23->Z23_NEWTAG := cTagGar+"R"+xSeq
													cTagR1 := cTagGar+"R"+xSeq
												ENDIF
												MsUnlock()										
											ENDIF

										//VERIFICA SE ENCERROU 	CONTROLE DE GARANTIA
										FINDZ23()	
									ENDIF
								ELSE
									dbselectarea("Z12")
									dbsetorder(3)
									IF !lOK
										//dbseek(xfilial("Z12")+SF1->F1_FORNECE+SF1->F1_LOJA+xPar07+cLote+"9999",.t.)
										dbseek(xfilial("Z12")+xPar04+xPar05+xPar07+cLote+"9999",.t.)
										dbskip(-1)
										if bof()
											cRetorno := cLote + "0001"
										else
											cRetorno := cLote+soma1(substr(Z12->Z12_TAG3,5,4))

										endif
										lOK := .T.
									ENDIF
									xSeq  := SOMA1(xSeq)

									//*************************************
									//Verifica se Baixa o ID garantia assetnum   //
									//*************************************
									xAsetnum := ""

									ValidaTAG4()			
									
								ENDIF
	
								IF RECLOCK("Z12",.T.)
								Z12->Z12_FILIAL  := XFILIAL("Z12")
								Z12->Z12_CODIGO	 := cSigla+xPar12
								Z12->Z12_SEQ     := strzero(VAL(xSeq),5)
								Z12->Z12_COD     := xPar07
								Z12->Z12_NUMSEQ	 := xPar12
								Z12->Z12_DTDIGI  := xPar17
								Z12->Z12_DIASGA  := xPar10
								Z12->Z12_EMISSAO := xPar17
								IF xPar11 == "G"
								Z12->Z12_TAG	 := cTagG1  //Ativar xPar11 para testar Garantia
								xTag			 := cTagG1  //Ativar xPar11 para testar Garantia										
								Z12->Z12_TAGORI  := cTagOri
								Z12->Z12_LOTECT	 := cXsigla
								ELSEIF xPar11 == "R"
								Z12->Z12_TAG	 := cTagR1  //Ativar xPar11 para testar Garantia
								xTag			 := cTagR1  //Ativar xPar11 para testar Garantia										
								Z12->Z12_TAGORI  := cTagOri
								Z12->Z12_LOTECT	 := cXsigla
								ELSE
								Z12->Z12_TAG	 := cSigla+xAsetnum+xPar07+cRetorno+cSigla+xAsetnum+"N"  //Ativar xPar11 para testar Garantia
								xTag			 := cSigla+xAsetnum+xPar07+cRetorno+cSigla+xAsetnum+"N"  //Ativar xPar11 para testar Garantia
								Z12->Z12_LOTECT	 := cSigla
								Z12->Z12_TAGORI  := cSigla+xAsetnum+xPar07+cRetorno+cSigla+xAsetnum+"N" 
								ENDIF
								Z12->Z12_TAG1	 := cSigla+xAsetnum
								Z12->Z12_TAG2	 := xPar07
								Z12->Z12_TAG3	 := cRetorno
								Z12->Z12_TAG4	 := xAsetnum
								IF xPar11 == "G"
								Z12->Z12_TAG5	 := xPar11+xSeq
								ELSEIF xPar11 == "R"
								Z12->Z12_TAG5	 := xPar11+xSeq
								ELSE
								Z12->Z12_TAG5	 := xPar11
								ENDIF
								Z12->Z12_CODFOR	 := xPar04//SF1->F1_FORNECE
								Z12->Z12_LOJA	 := xPar05//SF1->F1_LOJA
								Z12->Z12_DOC	 := xPar02//SF1->F1_DOC
								Z12->Z12_SERIE	 := xPar03//SF1->F1_SERIE	
								Z12->Z12_VALNF	 := xPar18//SF1->F1_VALBRUT	
								Z12->Z12_CC			:= cUB_CCID																	
								MsUnlock()
								ENDIF

								dbselectarea("Z10")
								IF 	RECLOCK("Z10",.T.)
									//GRAVA TABELA DE INTEGRAÇÃO MAXIMO
									Z10->Z10_FILIAL 	:= xFilial("Z10")
									Z10->Z10_INREG 	 	:= "SB2"
									Z10->Z10_DATA 		:= xPar17
									Z10->Z10_USUARI 	:= xPar19
									Z10->Z10_HORA  		:= time()
									Z10->Z10_MOVIME		:= '6' //Inclusao
									Z10->Z10_B1COD 		:= xPar07
									Z10->Z10_NNRDES		:= CLocdes							
									Z10->Z10_B1DESC		:= xDescB1
									Z10->Z10_UINDVU		:= SB1->B1_UINDVU
									Z10->Z10_UTIPMA		:= SB1->B1_UTIPMAT
									Z10->Z10_SIGARM		:= SUBSTR(cLote,1,3)
									Z10->Z10_CUSTD		:= cB1custD
									Z10->Z10_CUSMED     := xPar13/xPar08   //SD1->D1_CUSTO/SD1->D1_QUANT
									Z10->Z10_UPRC		:= xPar14  //SD1->D1_VUNIT //Sem acrescimo de imposto/desconto
									Z10->Z10_B2COD 		:= xPar07
									Z10->Z10_B2LOCA		:= xPar09
									Z10->Z10_SIGARM		:= SUBSTR(cLote,1,3)
									Z10->Z10_B2FILI		:= xFilial("SD1")
									Z10->Z10_B2CM1		:= cB1custD
									Z10->Z10_B2QATU		:= cB2saldo
									Z10->Z10_TAG		:= xTag //						CI011424LAM.MVM.0035-002SJM-070100001N
									Z10->Z10_ORIGEM		:= "MATA103"
									Z10->Z10_DESTIN		:= "MXASSET" //Enviar junto o ASSETSPEC
									Z10->Z10_FORNEC		:= xPar04//SF1->F1_FORNECE 
									Z10->Z10_LOJA 		:= xPar05//SF1->F1_LOJA
									Z10->Z10_DOC		:= xPar02//SF1->F1_DOC
									Z10->Z10_SERIE		:= xPar03//SF1->F1_SERIE
									Z10->Z10_DESCTP 	:= cUtippro
									Z10->Z10_TIPPRO		:= cZ16desc
									Z10->Z10_ASSETN		:= xAsetnum
									Z10->Z10_CC			:= cUB_CCID
									MsUnlock()                          
									Z10->(DBCLOSEAREA())
								ENDIF
								dbselectarea("Z10")
								IF 	RECLOCK("Z10",.T.)
									//GRAVA TABELA DE INTEGRAÇÃO MAXIMO
									Z10->Z10_FILIAL 	:= xFilial("Z10")
									Z10->Z10_INREG 	 	:= "SB2"
									Z10->Z10_DATA 		:= xPar17
									Z10->Z10_USUARI 	:= xPar19
									Z10->Z10_HORA  		:= time()
									Z10->Z10_MOVIME		:= '7' //Inclusao
									Z10->Z10_B1COD 		:= xPar07
									Z10->Z10_B1DESC		:= xDescB1
									Z10->Z10_NNRDES		:= CLocdes							
									Z10->Z10_UTIPMA		:= SB1->B1_UTIPMAT
									Z10->Z10_SIGARM		:= SUBSTR(cLote,1,3)
									Z10->Z10_TAG		:= xTag //						CI011424LAM.MVM.0035-002SJM-070100001N
									Z10->Z10_ORIGEM		:= "MATA103"
									Z10->Z10_DESTIN		:= "MXASSETSPEC" //Enviar junto o ASSETSPEC
									Z10->Z10_FORNEC		:= xPar04//SF1->F1_FORNECE 
									Z10->Z10_LOJA 		:= xPar05//SF1->F1_LOJA
									Z10->Z10_DOC		:= xPar02//SF1->F1_DOC
									Z10->Z10_SERIE		:= xPar03//SF1->F1_SERIE
									Z10->Z10_DESCTP 	:= cUtippro
									Z10->Z10_ASSETN	 	:= xAsetnum
									Z10->Z10_CC		 	:= cUB_CCID
									DO CASE
										CASE Alltrim(cUtippro) == "TIPOLAM"
										Z10->Z10_TIPPRO	:= cZ16desc      // - LAMPADAS  
										Z10->Z10_ULPDTP := SB1->B1_ULPDTP  //TIPO - MVM
										Z10->Z10_ULPDPO := SB1->B1_ULPDPOT // POTENCIA - 70
										Z10->Z10_ULPDEF := SB1->B1_ULPDEFI //EFICIENCIA  - 160
										Z10->Z10_ULPDVU := SB1->B1_ULPDVU  //VIDA UTIL  - 200
										CASE Alltrim(cUtippro) == "TIPO"
										Z10->Z10_TIPPRO	:= cZ16desc
										Z10->Z10_ULUMTP := SB1->B1_ULUMTP  // TIPO
										Z10->Z10_ULUMPO := SB1->B1_ULUMPOT //POTENCIA
										Z10->Z10_ULUMEF := SB1->B1_ULUMEFI //EFICIENCIA
										Z10->Z10_ULUMVU := SB1->B1_ULUMVU  //VIDA UTEIL
										CASE  Alltrim(cUtippro) == "TIPOPOSTE"
										Z10->Z10_TIPPRO	:= cZ16desc
										Z10->Z10_UPOSTP := SB1->B1_UPOSTP  ///TIPO
										Z10->Z10_UINDEF := ""
										CASE Alltrim(cUtippro) == "TIPOPROJETOR"
										Z10->Z10_TIPPRO	:= cZ16desc
										Z10->Z10_UPRJTP := SB1->B1_UPRJTP  //TIPO
										//Z10->Z10_UPROPO := SB1->B1_UPROPO  //POTENCIA
										Z10->Z10_UPRJEF := SB1->B1_UPRJEFI //EFICIENCIA
										CASE Alltrim(cUtippro) == "TIPO_REATOR"
										Z10->Z10_TIPPRO	:= cZ16desc
										Z10->Z10_UREATP := SB1->B1_UREATP  //TIPO
										Z10->Z10_UREAPO := SB1->B1_UREAPOT //POTENCIA
										Z10->Z10_UREAEF := SB1->B1_UREAEFI //EFICIENCIA
										Z10->Z10_UREAVU := SB1->B1_UREAVU  //VIDA UTIL
										CASE Alltrim(cUtippro) == "TIPO_RELE"
										Z10->Z10_TIPPRO	:= cZ16desc
										Z10->Z10_URELTP := SB1->B1_URELTP //TIPO
										Z10->Z10_URELVU := SB1->B1_URELVU//VIDA UTIL 
										Z10->Z10_UINDEF := ""
										CASE Alltrim(cUtippro) == "TIPOSUPORTE"
										Z10->Z10_TIPPRO	:= cZ16desc
										Z10->Z10_USUPTP := SB1->B1_USUPTP  //TIPO
										Z10->Z10_UINDEF := ""
										CASE Alltrim(cUtippro) == "TIPOAR"
										Z10->Z10_TIPPRO	:= cZ16desc
										Z10->Z10_UACDTP := SB1->B1_UACDTP  //TIPO
										Z10->Z10_UACDPO := SB1->B1_UACDPOT //POTENCIA
										Z10->Z10_UACDPT := SB1->B1_UACDPT  //POTENCIA TERMICA  
										Z10->Z10_UINDEF := ""
										CASE Alltrim(cUtippro) == "TIPOVENT"          
										Z10->Z10_TIPPRO	:= cZ16desc
										Z10->Z10_TIPPRO	:= ""
										Z10->Z10_UVENTP := SB1->B1_UVENTP  //TIPO
										Z10->Z10_UVENPO := SB1->B1_UVENPOT //POTENCIA
										CASE Alltrim(cUtippro) == "TIPOBRACO"
										Z10->Z10_TIPPRO	:= cZ16desc
										Z10->Z10_UBRCTP:= SB1->B1_UBRCTP 	//TIPO
										Z10->Z10_UINDEF := ""
										CASE Alltrim(cUtippro) == "CHUVEIRO"			
										Z10->Z10_TIPPRO	:= cZ16desc
										Z10->Z10_UCHUEF := SB1->B1_UCHUEFI //EFICIENCIA
										Z10->Z10_UCHUPO := SB1->B1_UCHUPOT //POTENCIA
										CASE Alltrim(cUtippro) == "BOMBA"		
										Z10->Z10_TIPPRO	:= cZ16desc
										Z10->Z10_UBOMPO := SB1->B1_UBONPOT //POTENCIA									
										Z10->Z10_UINDEF := ""
										CASE Alltrim(cUtippro) == "AQUECEDOR"
										Z10->Z10_TIPPRO	:= cZ16desc
										Z10->Z10_UAQSVO := SB1->B1_UAQSVOL //VOLUME DO BOLER
										Z10->Z10_UAQSPO := SB1->B1_UAQSPOT //POTENCIA
										Z10->Z10_UAQSAR := SB1->B1_UQSARE  //AREA COLETOR
										Z10->Z10_UAQSPE := SB1->B1_UAQSPEC //PRODUCAO ENERGIA
										Z10->Z10_UINDEF := ""
										OTHERWISE  
										Z10->Z10_TIPPRO	:= ""
										Z10->Z10_UINDEF := ""
									ENDCASE 
									MsUnlock()      
									Z10->(DBCLOSEAREA())
								ENDIF

								AADD(aAllTAgs,{xTag})
							ELSE
								LOOP
							ENDIF							

						NEXT _X
						DBSELECTAREA("Z10")
						if 	RECLOCK("Z10",.T.)
							//GRAVA TABELA DE INTEGRAÇÃO MAXIMO
							Z10->Z10_FILIAL 	:= xFilial("Z10")
							Z10->Z10_INREG 	 	:= "SD1"
							Z10->Z10_DATA 		:= xPar17
							Z10->Z10_USUARI 	:= xPar04//RetCodUsr()
							Z10->Z10_HORA  		:= time()
							Z10->Z10_MOVIME		:= '4' //Inclusao
							Z10->Z10_B1COD 		:= xPar07
							Z10->Z10_B1DESC		:= xDescB1
							Z10->Z10_B1UM  		:= SB1->B1_UM
							Z10->Z10_D3QTD 		:= xPar08//SD1->D1_QUANT
							Z10->Z10_UTIPMA		:= SB1->B1_UTIPMAT
							Z10->Z10_LOCAL		:= xPar09
							Z10->Z10_NNRDES		:= CLocdes
							Z10->Z10_SIGARM		:= SUBSTR(cLote,1,3)
							Z10->Z10_CUSTD		:= cB1custD
							Z10->Z10_CUSMED     := xPar13/xPar08 //SD1->D1_CUSTO/SD1->D1_QUANT
							Z10->Z10_UPRC		:= xPar14  //SD1->D1_VUNIT //Sem acrescimo de imposto/desconto
							Z10->Z10_ORIGEM		:= "MATA103"
							Z10->Z10_DESTIN		:= "MXINVENTORY" 
							Z10->Z10_FORNEC		:= xPar04 //SF1->F1_FORNECE 
							Z10->Z10_LOJA 		:= xPar05 //SF1->F1_LOJA
							Z10->Z10_DOC		:= xPar02 //SF1->F1_DOC
							Z10->Z10_SERIE		:= xPar06 //SF1->F1_SERIE
							Z10->Z10_CC			:= cUB_CCID //SF1->F1_SERIE
							MsUnlock()
							Z10->(DBCLOSEAREA())
							IF xGeratag =='N'
								DBSELECTAREA("Z10")
								IF RECLOCK("Z10",.T.)
									//GRAVA TABELA DE INTEGRAÇÃO MAXIMO
									Z10->Z10_FILIAL 	:= xFilial("Z10")
									Z10->Z10_INREG 	 	:= "SB2"
									Z10->Z10_DATA 		:= xPar17
									Z10->Z10_USUARI 	:= xPar19 //RetCodUsr()
									Z10->Z10_HORA  		:= time()
									Z10->Z10_MOVIME		:= '5' //Inclusao
									Z10->Z10_B1COD 		:= xPar07
									Z10->Z10_B1DESC		:= xDescB1
									Z10->Z10_NNRDES		:= CLocdes
									//							Z10->Z10_D3QTD 		:= SD1->D1_QUANT
									Z10->Z10_UTIPMA		:= SB1->B1_UTIPMAT
									Z10->Z10_LOCAL		:= xPar09
									Z10->Z10_SIGARM		:= SUBSTR(cLote,1,3)
									Z10->Z10_CUSTD		:= cB2cust
									Z10->Z10_CUSMED     := xPar13/xPar08 //SD1->D1_CUSTO/SD1->D1_QUANT
									Z10->Z10_UPRC		:= xPar14 //SD1->D1_VUNIT //Sem acrescimo de imposto/desconto
									Z10->Z10_B2COD 		:= xPar07
									Z10->Z10_B2LOCA		:= xPar09
									Z10->Z10_SIGARM		:= SUBSTR(cLote,1,3)
									Z10->Z10_B2FILI		:= xFilial("SD1")
									Z10->Z10_B2CM1		:= cB2cust
									Z10->Z10_B2QATU		:= cB2saldo
									Z10->Z10_ORIGEM		:= "MATA103"
									Z10->Z10_DESTIN		:= "MXINVBAL"
									Z10->Z10_FORNEC		:= xPar04//SF1->F1_FORNECE 
									Z10->Z10_LOJA 		:= xPar05//SF1->F1_LOJA
									Z10->Z10_DOC		:= xPar02//SF1->F1_DOC
									Z10->Z10_SERIE		:= xPar03//SF1->F1_SERIE		
									Z10->Z10_CC			:= cUB_CCID //SF1->F1_SERIE					
									MsUnlock()
									Z10->(DBCLOSEAREA())
								ENDIF
							ENDIF
						ENDIF
					ENDIF
				//ENDIF
			ENDIF

		if xGeratag == "S"
			Envmail(paramixb) //envia e-mail ao termino do processo para avisar usuarios
			aAllTAgs := {}
		endif

	NEXT _I

   DBSELECTAREA("Z24")//Z24_FILIAL+Z24_DOC+Z24_SERIE+Z24_FORNEC+Z24_LOJA+Z24_COD+Z24_ITEM
   Z24->(DBSetOrder(1))
   	CONOUT(xFilial("Z24")+xPar02+xPar03+xPar04+xPar05+xPar07+xPar06)
   if DBSeek(xFilial("Z24")+xPar02+xPar03+xPar04+xPar05+xPar07+xPar06)
   
   	CONOUT("POSICIONOU Z24")

		WHILE !EOF() .AND. Z24->Z24_FILIAL+Z24->Z24_DOC+Z24->Z24_SERIE+Z24->Z24_FORNEC+Z24->Z24_LOJA+Z24->Z24_COD+Z24->Z24_ITEM == xFilial("Z24")+xPar02+xPar03+xPar04+xPar05+xPar07+xPar06
			CONOUT("PASSOU WHILE")
			CONOUT(Z24->Z24_FILIAL+Z24->Z24_DOC+Z24->Z24_SERIE+Z24->Z24_FORNEC+Z24->Z24_LOJA+Z24->Z24_COD+Z24->Z24_ITEM)
			IF RECLOCK("Z24",.F.)
				Z24->Z24_OK := 'X'
			MSUNLOCK()
			ENDIF

		Z24->(DBSKIP())
		ENDDO
	
	endif


	IF !lDEBUG
		RESET ENVIRONMENT //DEBUG COMENTAR
	ENDIF

RETURN

/*/{Protheus.doc} FINDZ23

	/*/
Static Function FINDZ23()
Local 	CQUERY01 := ""

	//*************************************
	//Verifica se Baixa o ID garantia    //
	//*************************************

	CQUERY01 := " SELECT *"
	CQUERY01 += " FROM "+RETSQLNAME("Z23")+" Z23 "
	CQUERY01 += " WHERE  Z23_ID = '"+xPar15+"' AND  Z23_NEWTAG='' AND Z23.D_E_L_E_T_='' " //DAND Z23_COD='"+xPar07+"' "
	
	IF SELECT("TRB03")!=0
		TRB03->(DBCLOSEAREA())
	ENDIF
	TCQUERY CQUERY01 NEW ALIAS "TRB03" 
	DBSELECTAREA("TRB03")
	DBGOTOP()
	If TRB03->(eof())
		DBSELECTAREA("Z22") 
		DBSETORDER(1)
		IF DBSEEK(xFilial("Z22")+xPar15)
			IF RECLOCK("Z22",.F.)       
				Z22->Z22_STATUS := "3"
				MSUNLOCK()	
			ENDIF
		EndIf     
	ELSE
		DBSELECTAREA("Z22") 
		DBSETORDER(1)
		IF DBSEEK(xFilial("Z22")+xPar15)
			IF RECLOCK("Z22",.F.)       
				Z22->Z22_STATUS := "5"
				MSUNLOCK()	
			ENDIF
		EndIf 
	ENDIF

	TRB03->(DBCLOSEAREA())


RETURN

Static Function ValidaTAG4()
local lReT 		:= .t.
Local CQUERY02	:= ""
Local CQUERY03	:= ""

	WHILE lReT
		
		//xAsetnum := GetSxeNum("Z12","Z12_TAG4",1)
		//ConfirmSx8()


		//*************************************
		//Verifica se ja existe numeração    //
		//*************************************
		CQUERY02 := ""
		CQUERY02 := " SELECT MAX(Z12_TAG4) Z12_TAG4"
		CQUERY02 += " FROM "+RETSQLNAME("Z12")+" Z12 "
		CQUERY02 += " WHERE  Z12.D_E_L_E_T_=''  AND Z12_FILIAL = '"+xFilial("Z12")+"' AND Z12_LOTECT = '"+cSigla+"'  "

		IF SELECT("TRBASS")!=0
			TRBASS->(DBCLOSEAREA())
		ENDIF
		TCQUERY CQUERY02 NEW ALIAS "TRBASS" 
		DBSELECTAREA("TRBASS")
		DBGOTOP()
		If !TRBASS->(eof())
			xAsetnum := TRBASS->Z12_TAG4
			xAsetnum := STRZERO(val(xAsetnum),9)
			xAsetnum := SOMA1(xAsetnum)


		ENDIF
	
		//*************************************
		//Verifica se ja existe numeração    //
		//*************************************
		CQUERY03 := ""
		CQUERY03 := " SELECT *"
		CQUERY03 += " FROM "+RETSQLNAME("Z12")+" Z12 "
		CQUERY03 += " WHERE  Z12_TAG4 = '"+xAsetnum+"' AND Z12.D_E_L_E_T_=''  AND Z12_FILIAL = '"+xFilial("Z12")+"' AND Z12_LOTECT = '"+cSigla+"'  "

		IF SELECT("TRB04")!=0
			TRB04->(DBCLOSEAREA())
		ENDIF
		TCQUERY CQUERY03 NEW ALIAS "TRB04" 
		DBSELECTAREA("TRB04")
		DBGOTOP()
		If !TRB04->(eof())
			loop
		else	
			lRet := .F.
		ENDIF

		IF EMPTY(xAsetnum) .OR. xAsetnum ==''
			xAsetnum := '000000001'
		ENDIF

		IF xAsetnum > '999999999'
			cSigla := SOMA1(cSigla)
			PUTMV( "MV_UTAGSG", cSigla)
			xAsetnum:= '000000001'
		ENDIF
		

		TRB04->(DBCLOSEAREA())
	ENDDO


Return 


STATIC FUNCTION TEMPJOB(_aParametros) //
Local _x

	DBSELECTAREA("Z24")//Z24_FILIAL+Z24_DOC+Z24_SERIE+Z24_FORNEC+Z24_LOJA+Z24_COD+Z24_ITEM

	FOR _x:=1 TO LEN(_aParametros) //FOR POR ITEM

		IF RECLOCK("Z24",.T.)
			Z24->Z24_EMPRES		:= _aParametros[_x,01]//Empresa
			Z24->Z24_FILIAL		:= _aParametros[_x,02]//Filial
			Z24->Z24_DOC		:= _aParametros[_x,03]//Documento
			Z24->Z24_SERIE		:= _aParametros[_x,04]//Serie
			Z24->Z24_FORNEC		:= _aParametros[_x,05]//Fornecedor
			Z24->Z24_LOJA		:= _aParametros[_x,06]//Loja
			Z24->Z24_ITEM		:= _aParametros[_x,07]//Item
			Z24->Z24_COD		:= _aParametros[_x,08]//Codigo
			Z24->Z24_QUANT		:= _aParametros[_x,09]//Quantidade
			Z24->Z24_LOCAL		:= _aParametros[_x,10]//Local 
			Z24->Z24_DIAS		:= _aParametros[_x,11]//Dias
			Z24->Z24_NUMSEQ		:= _aParametros[_x,12]//Numseq
			Z24->Z24_CUSTO1		:= _aParametros[_x,14]//custo1
			Z24->Z24_VUNIT		:= _aParametros[_x,15]//vlrunit
			Z24->Z24_IDGARA		:= _aParametros[_x,16]//id Garantia
			Z24->Z24_VALBRUT	:= _aParametros[_x,19]//Valor Total
			MSUNLOCK()
		ENDIF

	Next _x

Return

Static Function Envmail(_aParametros)
	Local a
	Private MVTAGJOB  := SuperGetMV("MV_UJOBTAG",.F.,"")
	Private cMsg
	Private cPass      := GETMV("MV_RELPSW")
	Private cAccount   := GETMV("MV_RELACNT")
	Private cServer    := GETMV("MV_RELSERV")
	Private cUsrMail   := GETMV("MV_RELACNT")
	Private csenha     := GETMV("MV_RELAPSW")
	Private cPara      := MVTAGJOB
	IF lDEBUG
		cPara      := "everton.forti@totvs.com.br"//debug
	ENDIF
	Private cAssunto   	:= 'TAG GERADAS COM SUCESSO  '+ ALLTRIM(SM0->M0_NOMECOM)+' - Filial: '+SM0->M0_FILIAL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Inicia montagem do html com os dados da proposta de cotação recebida\processada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	cMsg := ""
	cMsg := '<html>'
	cMsg += '<head>'
	cMsg += '<title>Etiquetas geradas com Suesso</title>'
	cMsg += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
	cMsg := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
	cMsg += '<html xmlns="http://www.w3.org/1999/xhtml">'+ CRLF
	cMsg += '<head>'+ CRLF
	cMsg += '<title> Etiquetas geradas com Suesso</title>'+ CRLF
	cMsg += '<style type="text/css">'
	cMsg += '<!--'
	cMsg += '.style8 {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; }'
	cMsg += '.style13 {color: #0033FF; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; }'
	cMsg += '-->'
	cMsg += '</style>'
	cMsg += '</head>'
	cMsg += ' '
	cMsg += '<body>'
	cMsg += '<hr align="left" width="826">'
	cMsg += '<table width="827" border="0">'
	cMsg += '  </tr>'    
	cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">'+ALLTRIM(SM0->M0_NOMECOM)+' - Filial: '+SM0->M0_FILIAL+ '</div></th> '
	cMsg += '  </tr>
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Etiquetas geradas com sucesso!</div></th> '
	cMsg += '  </tr>	
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Empresa: ' + xPar00+ '</div></th>'
		cMsg += '  </tr>
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Filial: ' + xPar01+ '</div></th>'
		cMsg += '  </tr>
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Documento: ' + xPar02+ '</div></th>'
		cMsg += '  </tr>
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Serie: ' + xPar03+ '</div></th>'
		cMsg += '  </tr>
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Fornece:  ' + xPar04+ '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Loja: ' +xPar05 + '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Item: ' + xPar06+ '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Codigo: ' + xPar07+ '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Quantidade: ' + CVALTOCHAR(xPar08) + '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Local: ' + xPar09+ '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Dias Garantia: ' + xPar10+ '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Status: ' + xPar11+ '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Valor Unitário: ' + CVALTOCHAR(xPar14) + '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">ID Garantia: ' + xPar15+ '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Emissão: ' + DTOC(xPar17)+ '</div></th>'
	cMsg += '  </tr>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Tempo Inicio: ' + xPar20+ '</div></th>'
	cMsg += '  </tr>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Tempo Fim: ' + Time() + '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  </tr>'

	if len(aAllTAgs) > 0
		for a:=01 to len(aAllTAgs)
			cMsg += '  <tr>'
			cMsg += '  <th width="674" scope="col"><div align="left">TAG ' +CVALTOCHAR(a)+" - "+ aAllTAgs[a][01]+ '</div></th>'
			cMsg += '  </tr>'
		next a
	endif

	cMsg += '</table>
	cMsg += '</body>'
	cMsg += '</html>'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Efetua o envio do e-mail de aviso ao departamento de compras³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !EMPTY(cPara)
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass Result lConectou

		If lConectou


			MAILAUTH(cAccount, cPass)

			SEND MAIL FROM ALLTRIM(cAccount) TO cPara SUBJECT cAssunto BODY cMsg Result lConectou

			If !lConectou

				GET MAIL ERROR cSmtpError

			Endif

		EndIf

		DISCONNECT SMTP SERVER
	EndIf

Return .T.
