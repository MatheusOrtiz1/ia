#Include "RPTDEF.CH"
#Include "TOTVS.CH"
#INCLUDE "TOTVSWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#Include "rwmake.ch"
#Include "tbiconn.ch"

User Function FEEDSZ8()
Local i      
//wfprepenv("25","01")
PREPARE ENVIRONMENT EMPRESA "25" FILIAL "01"
      
aDados := {}


aadd(aDados,{"26","24101001"})
aadd(aDados,{"26","24101002"})
aadd(aDados,{"26","24102001"})
aadd(aDados,{"26","24103001"})
aadd(aDados,{"26","24103002"})
aadd(aDados,{"26","24103003"})
aadd(aDados,{"26","24103004"})
aadd(aDados,{"26","24103005"})
aadd(aDados,{"26","24104001"})
aadd(aDados,{"26","24104002"})
aadd(aDados,{"26","24105001"})
aadd(aDados,{"26","24105002"})
                              
aadd(aDados,{"29","24101001"})
aadd(aDados,{"29","24101002"})
aadd(aDados,{"29","24102001"})
aadd(aDados,{"29","24103001"})
aadd(aDados,{"29","24103002"})
aadd(aDados,{"29","24103003"})
aadd(aDados,{"29","24103004"})
aadd(aDados,{"29","24103005"})
aadd(aDados,{"29","24104001"})
aadd(aDados,{"29","24104002"})
aadd(aDados,{"29","24105001"})
aadd(aDados,{"29","24105002"})

aadd(aDados,{"28","24101001"})
aadd(aDados,{"28","24101002"})
aadd(aDados,{"28","24102001"})
aadd(aDados,{"28","24103001"})
aadd(aDados,{"28","24103002"})
aadd(aDados,{"28","24103003"})
aadd(aDados,{"28","24103004"})
aadd(aDados,{"28","24103005"})
aadd(aDados,{"28","24104001"})
aadd(aDados,{"28","24104002"})
aadd(aDados,{"28","24105001"})
aadd(aDados,{"28","24105002"})

aadd(aDados,{"23","24101001"})
aadd(aDados,{"23","24101002"})
aadd(aDados,{"23","24102001"})
aadd(aDados,{"23","24103001"})
aadd(aDados,{"23","24103002"})
aadd(aDados,{"23","24103003"})
aadd(aDados,{"23","24103004"})
aadd(aDados,{"23","24103005"})
aadd(aDados,{"23","24104001"})
aadd(aDados,{"23","24104002"})
aadd(aDados,{"23","24105001"})
aadd(aDados,{"23","24105002"})
                              
aadd(aDados,{"07","22129016"})
aadd(aDados,{"07","22130017"})

aadd(aDados,{"07","22120001"})
aadd(aDados,{"26","22120001"})
aadd(aDados,{"25","22120001"})
aadd(aDados,{"28","22120001"})
aadd(aDados,{"29","22120001"})
                
aadd(aDados,{"07","22115001"})
aadd(aDados,{"26","22115001"})
aadd(aDados,{"25","22115001"})
aadd(aDados,{"28","22115001"})
aadd(aDados,{"29","22115001"})
                              
aadd(aDados,{"28","22105020"})

aadd(aDados,{"23","22107001"})
                           
aadd(aDados,{"23","21130001"})
aadd(aDados,{"29","21130001"})
aadd(aDados,{"26","21130001"})
aadd(aDados,{"28","21130001"})

aadd(aDados,{"28","21105020"})
aadd(aDados,{"23","1124001"})
aadd(aDados,{"23","21124001"})
aadd(aDados,{"29","21124001"})
aadd(aDados,{"26","21124001"})
                              
aadd(aDados,{"23","21101001088375500000"})
aadd(aDados,{"26","21101001088375500000"})
aadd(aDados,{"28","21101001088375500000"})

aadd(aDados,{"07","12503018"})
aadd(aDados,{"07","12503019"})
aadd(aDados,{"07","12504019"})
aadd(aDados,{"07","12901003"})
aadd(aDados,{"07","12902003"})

aadd(aDados,{"07","12106002"})

aadd(aDados,{"07","12501002"})
aadd(aDados,{"07","12501003"})
aadd(aDados,{"07","12501015"})
aadd(aDados,{"07","12501016"})
aadd(aDados,{"07","12501017"})
aadd(aDados,{"07","12501018"})
aadd(aDados,{"07","12501019"})
aadd(aDados,{"07","12502001"})
aadd(aDados,{"07","12502002"})
aadd(aDados,{"07","12502003"})
aadd(aDados,{"07","12502015"})
aadd(aDados,{"07","12502016"})
aadd(aDados,{"07","12502017"})
aadd(aDados,{"07","12502018"})
aadd(aDados,{"07","12502019"})

aadd(aDados,{"07","11201001062201970001"})
aadd(aDados,{"07","11201001084972300001"})
aadd(aDados,{"07","11201001202204460001"})
aadd(aDados,{"07","11201001626486880001"})

aadd(aDados,{"07","11206002"})
aadd(aDados,{"07","11206015"})
aadd(aDados,{"07","11206016"})
aadd(aDados,{"07","11206017"})
aadd(aDados,{"07","11206018"})
aadd(aDados,{"07","11206019"})

aadd(aDados,{"07","11202002"})
aadd(aDados,{"07","11202003"})
aadd(aDados,{"07","11202004"})
aadd(aDados,{"07","11202005"})
aadd(aDados,{"07","11202006"})

aadd(aDados,{"07","11213002"})
aadd(aDados,{"07","11213015"})
aadd(aDados,{"07","11213019"})

aadd(aDados,{"07","12101002"})
aadd(aDados,{"07","12101003"})
aadd(aDados,{"07","12101004"})
aadd(aDados,{"07","12101015"})
aadd(aDados,{"07","12101016"})
aadd(aDados,{"07","12101017"})
aadd(aDados,{"07","12101018"})
aadd(aDados,{"07","12101019"})

aadd(aDados,{"07","12102002"})
aadd(aDados,{"07","12102003"})
aadd(aDados,{"07","12102004"})
aadd(aDados,{"07","12102015"})
aadd(aDados,{"07","12102016"})
aadd(aDados,{"07","12102017"})
aadd(aDados,{"07","12102018"})
aadd(aDados,{"07","12102019"})

aadd(aDados,{"07","12110002"})
aadd(aDados,{"07","12110003"})
aadd(aDados,{"07","12110004"})
aadd(aDados,{"07","12110015"})
aadd(aDados,{"07","12110016"})
aadd(aDados,{"07","12110017"})
aadd(aDados,{"07","12110018"})
aadd(aDados,{"07","12110019"})
            
for i:=1 to len(aDados)
	dbselectarea("CT1")
	dbsetorder(1)
	if dbseek(xFilial()+aDados[i,2])
		dbselectarea("SZ8")
		dbsetorder(1)//Z8_FILIAL+Z8_CONTA+Z8_EMPRESA
		if !dbseek(xFilial()+CT1->CT1_CONTA+aDados[i,1])
			reclock("SZ8",.T.)
			SZ8->Z8_FILIAL  := xFilial()
			SZ8->Z8_EMPRESA := aDados[i,1]
			SZ8->Z8_CONTA   := CT1->CT1_CONTA
			SZ8->Z8_PERCENT := 100
			msunlock()
		endif
	endif
next


Return