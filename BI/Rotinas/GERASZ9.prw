#include "protheus.ch"
#include "topconn.ch"

//funcao pra gerar registros na SZ'9

User Function GERASZ9()
Private cPerg := "GERASZ9"

validperg()

if !pergunte(cPerg,.t.)
	return
endif

cQuery := " SELECT '07' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_CREDIT AS COD_CONTA,
cQuery += " 0 AS VALOR_DEB,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2070 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '
cQuery += " AND CT2_LP='610' AND SUBSTRING(CT2_KEY,15,6) IN ('000018','000015','000002')
cQuery += " AND NOT (CT2_CREDIT='32201001' AND CT2_HIST LIKE '%SANESALTO%' )
cQuery += " AND (CT2_DC='2' OR CT2_DC='3')
cQuery += " AND CT2_CREDIT NOT IN ('61103002','61103015','61103016','61103017','61103018','61103019','71201006','71201090')
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "
cQuery += " UNION ALL "
cQuery += " SELECT '07' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_CREDIT AS COD_CONTA,
cQuery += " 0 AS VALOR_DEB,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2070 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '
cQuery += " AND CT2_LP='500' AND SUBSTRING(CT2_KEY,3,6) IN ('000018')
cQuery += " AND CT2_CREDIT='32201008' 
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "
cQuery += " UNION ALL
cQuery += " SELECT '07' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_DEBITO AS COD_CONTA,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_DEB,
cQuery += " 0 AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2070 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '
cQuery += " AND CT2_LP='610' AND SUBSTRING(CT2_KEY,15,6) IN ('000018','000015','000002')
cQuery += " AND (CT2_DC='1' OR CT2_DC='3')
cQuery += " AND CT2_DEBITO NOT IN ('61103002','61103015','61103016','61103017','61103018','61103019','71201006','71201090')
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "
cQuery += " UNION ALL
cQuery += " SELECT '23' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_CREDIT AS COD_CONTA,
cQuery += " 0 AS VALOR_DEB,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2230 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '
cQuery += " AND CT2_LP='650' AND SUBSTRING(CT2_KEY,15,6) IN ('001376')
cQuery += " AND (CT2_DC='2' OR CT2_DC='3')
cQuery += " AND CT2_CREDIT NOT IN ('71101001','71101010')                          
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "
cQuery += " UNION ALL
cQuery += " SELECT '23' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_DEBITO AS COD_CONTA,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_DEB,
cQuery += " 0 AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2230 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '
cQuery += " AND CT2_LP='650' AND SUBSTRING(CT2_KEY,15,6) IN ('001376')
cQuery += " AND (CT2_DC='1' OR CT2_DC='3')
cQuery += " AND CT2_DEBITO NOT IN ('71101001','71101010')                          
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "                                   
cQuery += " UNION ALL
cQuery += " SELECT '23' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_DEBITO AS COD_CONTA,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_DEB,
cQuery += " 0 AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2230 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '
cQuery += " AND (CT2_DC='2' OR CT2_DC='3')                                         
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "     
cQuery += " AND CT2_LP='510' AND CT2_DEBITO='51101023' AND CT2_HIST LIKE '%CONASA%'
cQuery += " UNION ALL
cQuery += " SELECT '28' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_DEBITO AS COD_CONTA,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_DEB,
cQuery += " 0 AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2280 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '
cQuery += " AND CT2_LP='510' AND CT2_DEBITO='51101023' AND CT2_HIST LIKE '%CONASA%'
cQuery += " AND (CT2_DC='2' OR CT2_DC='3')                                         
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "
cQuery += " UNION ALL
cQuery += " SELECT '28' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_CREDIT AS COD_CONTA,
cQuery += " 0 AS VALOR_DEB,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2280 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '
cQuery += " AND CT2_LP='650' AND SUBSTRING(CT2_KEY,15,9) IN ('088375560')
cQuery += " AND (CT2_DC='2' OR CT2_DC='3')                                         
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "
cQuery += " UNION ALL
cQuery += " SELECT '28' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_DEBITO AS COD_CONTA,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_DEB,
cQuery += " 0 AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2280 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '                                    
cQuery += " AND CT2_LP='650' AND SUBSTRING(CT2_KEY,15,9) IN ('088375560')
cQuery += " AND (CT2_DC='1' OR CT2_DC='3')                                         
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "
cQuery += " UNION ALL
cQuery += " SELECT '07' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_CREDIT AS COD_CONTA,
cQuery += " 0 AS VALOR_DEB,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2070 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '
cQuery += " AND CT2_LP='500' AND SUBSTRING(CT2_KEY,3,6) IN ('000002')
cQuery += " AND (CT2_DC='2' OR CT2_DC='3')
cQuery += " AND CT2_CREDIT NOT IN ('61103002','61103015','61103016','61103017','61103018','61103019','71201006','71201090')
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "
cQuery += " UNION ALL
cQuery += " SELECT '07' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_DEBITO AS COD_CONTA,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_DEB,
cQuery += " 0 AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2070 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '
cQuery += " AND CT2_LP='500' AND SUBSTRING(CT2_KEY,3,6) IN ('000002')
cQuery += " AND (CT2_DC='1' OR CT2_DC='3')
cQuery += " AND CT2_DEBITO NOT IN ('61103002','61103015','61103016','61103017','61103018','61103019','71201006','71201090')
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "
cQuery += " UNION ALL
cQuery += " SELECT '23' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_CREDIT AS COD_CONTA,
cQuery += " 0 AS VALOR_DEB,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2230 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '
cQuery += " AND CT2_LP='510' AND SUBSTRING(CT2_KEY,21,6) IN ('001376')
cQuery += " AND (CT2_DC='2' OR CT2_DC='3')                                         
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "
cQuery += " UNION ALL
cQuery += " SELECT '23' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_DEBITO AS COD_CONTA,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_DEB,
cQuery += " 0 AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2230 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '
cQuery += " AND CT2_LP='510' AND SUBSTRING(CT2_KEY,21,6) IN ('001376')
cQuery += " AND (CT2_DC='1' OR CT2_DC='3')
cQuery += " AND CT2_DEBITO NOT IN ('71101001','71101010')                          
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "
cQuery += " UNION ALL
cQuery += " SELECT '28' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_CREDIT AS COD_CONTA,
cQuery += " 0 AS VALOR_DEB,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2280 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '
cQuery += " AND CT2_LP='510' AND SUBSTRING(CT2_KEY,21,9) IN ('088375560')
cQuery += " AND (CT2_DC='2' OR CT2_DC='3')
cQuery += " AND CT2_CREDIT NOT IN ('71101001','71101010')                          
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "
cQuery += " UNION ALL
cQuery += " SELECT '28' AS EMPRESA,SUBSTRING(CT2_DATA,5,2) AS MES, CT2_DATA,
cQuery += " CT2_DEBITO AS COD_CONTA,
cQuery += " CONVERT(NUMERIC(14,2),CT2_VALOR) AS VALOR_DEB,
cQuery += " 0 AS VALOR_CRD,
cQuery += " RTRIM(CT2_HIST) AS HISTORICO, CT2_CCD AS CC_DEBITO,
cQuery += " CT2_CCC AS CC_CREDITO, RTRIM(CT2_ORIGEM) AS ORIGEM, CT2_HIST
cQuery += " FROM PROTHEUS.dbo.CT2280 CT2
cQuery += " WHERE CT2.D_E_L_E_T_=' '
cQuery += " AND CT2_LP='510' AND SUBSTRING(CT2_KEY,21,9) IN ('088375560')
cQuery += " AND (CT2_DC='1' OR CT2_DC='3')
cQuery += " AND CT2_DATA>='"+DTOS(MV_PAR01)+"' AND CT2_DATA<='"+DTOS(MV_PAR02)+"' "
TCQUERY cQuery NEW ALIAS "TEMP"

dbselectarea("TEMP")
if !eof()
	PROCESSA({|| GERASZ8()},"Gerando Dados")
endif
TEMP->(dbclosearea())

return

static function GERASZ8()

dbselectarea("TEMP")
while !eof()
	cQuery1 := " SELECT Z9_EMPRESA, Z9_DATA, Z9_HIST "
	cQuery1 += " FROM "+RetSqlName("SZ9")+" WHERE D_E_L_E_T_=' '
	cQuery1 += " AND Z9_EMPRESA='"+TEMP->EMPRESA+"'
	cQuery1 += " AND Z9_DATA='"+TEMP->CT2_DATA+"'
	cQuery1 += " AND Z9_HIST='"+TEMP->CT2_HIST+"'
	TCQUERY cQuery1 NEW ALIAS "TEMP1"
	DBSELECTAREA("TEMP1")
	if eof()
		dbselectarea("SZ9")
		reclock("SZ9",.T.)
		SZ9->Z9_FILIAL  := xFilial("SZ9")
		SZ9->Z9_EMPRESA := TEMP->EMPRESA
		IF TEMP->VALOR_DEB>0
			SZ9->Z9_DEBITO := TEMP->COD_CONTA
			SZ9->Z9_VALOR := TEMP->VALOR_DEB
		ELSE
			SZ9->Z9_CREDITO	:= TEMP->COD_CONTA
			SZ9->Z9_VALOR := TEMP->VALOR_CRD
		ENDIF
		SZ9->Z9_DATA := STOD(TEMP->CT2_DATA)
		SZ9->Z9_HIST := TEMP->CT2_HIST
		msunlock()
	endif
	TEMP1->(dbclosearea())
	
	dbselectarea("TEMP")
	dbskip()
enddo

return

Static Function ValidPerg()

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10) 


//Grupo/Ordem/Pergunta/PerSPA/PerENG/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/DefSPA1/DefENG1/Cnt01/Var02/Def02/DefSPA2/DefENG2/Cnt02/Var03/Def03/DefSPA3/DefENG3/Cnt03/Var04/Def04/DefSPA4/DefENG4/Cnt04/Var05/Def05/DefSPA5/DefENG5/Cnt05/F3/GRPSXG
AADD(aRegs,{cPerg,"01","Data De            ?","","","mv_ch1","D",8,0,1,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data Ate           ?","","","mv_ch2","D",8,0,1,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
    If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Endif
        Next
        MsUnlock()
    Endif
Next
dbSelectArea(_sAlias)

Return