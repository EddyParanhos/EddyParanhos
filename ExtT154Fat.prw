#INCLUDE "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TBICONN.CH"
#include "topconn.ch"
#Include 'FILEIO.CH'

/*--------------------------------------------------------------------*
| Func:  ExtT154Fat()                                                 |
| Autor: Edmar Paranhos                                               |
| Data:  31/01/2019                                                   |
| Desc:  Gera arquivo TXT no layout TAF dos titulos com Retenção.     |
| Obs.:  \                                                            |
*---------------------------------------------------------------------*/

User Function ExtT154Fat()

	Local Nx
	Local nY
	Local lErroPrc := .F.
	Local dDtini := date()
	Local dDtfim := date()
	Local cQuery := ""
	Private oDlg, oDlg1
	Private lOk
	Private lContinua := .T.
	Private nNumNf := 0
	Private cSerie := 0
	Private dDataE
	Private cDir   := "C:\Temp\"
	Private cNomeArq := Space(25)
	Private cFcorr := cFilAnt 
	Private cEmpc  := cEmpAnt 
	Private cUfFil  := Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_ESTENT")
	Private cIeFil  := Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_INSC")
	Private nValctb := 0
	Private cNature := ""
	Private cCliFor := ""
	Private cLojaCF := ""
	Private cCF2    := ""
	Private nBasIns := 0
	Private nValIns := 0
	Private nBasIns := 0
	Private cCodSer := ""
	Private cTpServ := ""
	Private cCodISS := ""
	Private cRazaoS := "" 
	Private cCgcCpf := "" 
	Private cLograd := "" 
	Private cCodMun := ""
	Private cUf		:= "" 
	Private cCprb	:= "0" //0 = Não|1 = Sim

	MsgInfo("Esta rotina irá gerar o arquivo .TXT Layout TAF apenas para a filial Logada!","Informação!")

	DEFINE MSDIALOG oDlg1 FROM 096,042 TO 343,520 TITLE OemToAnsi("Arquivo Texto Layout TAF") PIXEL
	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD


	@ 007,025 SAY "Data Inicial"  of oDlg1 PIXEL
	@ 016,025 Get dDtini Size 50,09   of oDlg1 PIXEL

	@ 030,025 SAY "Data Final"  of oDlg1 PIXEL
	@ 038,025 MsGet dDtfim Size 50,09 Of oDlg Pixel

	@ 053,025 SAY "Drive Destino:"  of oDlg1 PIXEL
	@ 060,025 MsGet cDir PICTURE "@!" Size 45,09 Of oDlg Pixel //PICTURE "@!"

	@ 073,025 SAY "Nome do Arquivo:"  of oDlg1 PIXEL
	@ 082,025 MsGet cNomeArq PICTURE "@!" Size 69,09 Of oDlg Pixel //PICTURE "@!"

	@ 010,93 SAY "Gera Notas de Serviços Tomados/Prestados com" of oDlg1 PIXEL
	@ 017,93 SAY "Retenção referente ao periodo selecionado." of oDlg1 PIXEL

	@ 025,93 SAY "Cria arquivo .TXT para importação no SIGATAF." of oDlg1 PIXEL

	@ 031,88 BITMAP oBitmap1 SIZE 126, 064 OF oDlg NOBORDER FILENAME "\system\reinf.bmp" PIXEL

	@ 100,55  BUTTON "Processar"  SIZE 55 ,15   	FONT oDlg1:oFont  OF oDlg1 PIXEL ACTION (lContinua := .T.,ODlg1:End())
	@ 100,130 BUTTON "Cancelar"   SIZE 55 ,15       FONT oDlg1:oFont  OF oDlg1 PIXEL ACTION (lContinua := .F.,ODlg1:End())
	ACTIVATE MSDIALOG oDlg1 CENTERED


	If lContinua .And. (Empty(dDtini) .Or. Empty(dDtfim))
		HELP(2,"ARQT154","Datas Invalidas, favor preencha novamente!")

	ElseIf lContinua


		FWMsgRun(, {|| lErroPrc := GeraT154F( dDtini,dDtfim) }, "Processando Arquivo.", "Gerando Layout TAF, Aguarde!")

		If !lErroPrc
			MsgInfo('Arquivo .TXT gerado com sucesso!')
		Else
			Alert('Erro para atualizar.')
		Endif

	Endif

Return


/*--------------------------------------------------------------------*
| Func:  GeraT154F ()                                                 |
| Autor: Edmar Paranhos                                               |
| Data:  31/01/2019                                                   |
| Desc:  Realiza o Select e alimenta os Arrays para cada Layouts.     |
| Obs.:  Busca Valor e Base INSS da SD1/SD2 (Regra GPS).              |
*---------------------------------------------------------------------*/

Static Function GeraT154F  (dDtini,dDtfim)

	Local aReg003:= {} 
	Local aReg154:= {} 
	Local aR154AA:= {}
	Local aR154AB:= {}
	Local cLin 

	If Select("TMP154") > 0
		dbSelectArea("TMP154")
		dbCloseArea()
	EndIf

	cQuery := 'SELECT SF3.R_E_C_N_O_ AS RECNOSF3,F3_NFISCAL, F3_FILIAL, F3_ENTRADA, F3_EMISSAO, F3_SERIE, F3_CLIEFOR, F3_LOJA,A2_CGC AS "CNPJ",A2_NOME AS "NOME", A2_END AS "_END", A2_COD_MUN AS "CODMUN", A2_EST AS "EST", F3_VALCONT, F3_TIPO, FT_TIPOMOV,F3_CODISS, SUM(D1_BASEINS) AS BASE_INSS , SUM(D1_VALINS) AS VLR_INSS'+ CRLF 
	cQuery += " FROM "+RetSqlName("SFT") +" SFT " + CRLF 
	cQuery += " INNER JOIN " + RetSqlName("SF3") + " SF3 ON (FT_NFISCAL = F3_NFISCAL)" + CRLF  
	cQuery += " AND (FT_SERIE = F3_SERIE)" + CRLF
	cQuery += " AND (FT_CLIEFOR = F3_CLIEFOR)" + CRLF  
	cQuery += " AND (FT_LOJA = F3_LOJA) " + CRLF 
	cQuery += " INNER JOIN " + RetSqlName("SD1") + " SD1 ON (D1_DOC = FT_NFISCAL)" + CRLF  
	cQuery += " AND (FT_SERIE = D1_SERIE)" + CRLF
	cQuery += " AND (FT_CLIEFOR = D1_FORNECE)" + CRLF  
	cQuery += " AND (FT_LOJA = D1_LOJA) " + CRLF 
	cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 ON (A2_COD = F3_CLIEFOR)" + CRLF 
	cQuery += " AND (A2_LOJA = F3_LOJA) " + CRLF 	
	cQuery += " WHERE SFT.FT_FILIAL = '" + xFilial ("SFT") + "' " + CRLF 
	cQuery += "   AND SFT.FT_TIPO = 'S' " + CRLF 
	cQuery += "   AND SD1.D1_BASEINS <> 0 " + CRLF 
	cQuery += "   AND SD1.D1_VALINS  <> 0 " + CRLF 
	cQuery += "   AND SD1.D1_ALIQINS <> 0 " + CRLF 
	cQuery += "   AND SFT.FT_EMISSAO >= '"+DTOS(dDtini)+"' " + CRLF 
	cQuery += "   AND SFT.FT_EMISSAO <=  '"+DTOS(dDtfim)+"' " + CRLF 
	cQuery += "   AND SFT.FT_DTCANC = ' '" + CRLF
	cQuery += "   AND SA2.A2_TIPO = 'J'" + CRLF
	cQuery += "   AND SA2.A2_RECINSS = 'S'" + CRLF
	cQuery += "   AND SFT.D_E_L_E_T_ = ' ' " + CRLF  
	cQuery += "   AND SF3.D_E_L_E_T_ = ' ' " + CRLF 
	cQuery += "   AND SD1.D_E_L_E_T_ = ' ' " + CRLF 
	cQuery += "   GROUP BY SF3.R_E_C_N_O_,F3_NFISCAL, F3_FILIAL, F3_ENTRADA, F3_EMISSAO, F3_SERIE, F3_CLIEFOR, F3_LOJA,A2_CGC, A2_NOME, A2_END, A2_COD_MUN ,A2_EST, F3_VALCONT, F3_TIPO, FT_TIPOMOV,F3_CODISS" + CRLF 
	cQuery += "   UNION ALL " + CRLF 	
	cQuery += 'SELECT SF3.R_E_C_N_O_ AS RECNOSF3,F3_NFISCAL, F3_FILIAL, F3_ENTRADA, F3_EMISSAO, F3_SERIE, F3_CLIEFOR, F3_LOJA, A1_CGC "CNPJ", A1_NOME AS "NOME",A1_END AS "_END", A1_COD_MUN AS "CODMUN",A1_EST AS "EST",F3_VALCONT, F3_TIPO, FT_TIPOMOV,F3_CODISS, SUM(D2_BASEINS) AS BASE_INSS , SUM(D2_VALINS) AS VLR_INSS' + CRLF
	cQuery += " FROM "+RetSqlName("SFT") +" SFT " + CRLF 
	cQuery += " INNER JOIN " + RetSqlName("SF3") + " SF3 ON (FT_NFISCAL = F3_NFISCAL)" + CRLF  
	cQuery += " AND (FT_SERIE = F3_SERIE)" + CRLF
	cQuery += " AND (FT_CLIEFOR = F3_CLIEFOR)" + CRLF  
	cQuery += " AND (FT_LOJA = F3_LOJA) " + CRLF 
	cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 ON (D2_DOC = FT_NFISCAL)" + CRLF  
	cQuery += " AND (FT_SERIE = D2_SERIE)" + CRLF
	cQuery += " AND (FT_CLIEFOR = D2_CLIENTE)" + CRLF  
	cQuery += " AND (FT_LOJA = D2_LOJA) " + CRLF 
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON (A1_COD = F3_CLIEFOR)" + CRLF 
	cQuery += " AND (A1_LOJA = F3_LOJA) " + CRLF	
	cQuery += " WHERE SFT.FT_FILIAL = '" + xFilial ("SFT") + "' " + CRLF 
	cQuery += "   AND SFT.FT_TIPO = 'S' " + CRLF 
	cQuery += "   AND SD2.D2_BASEINS <> 0 " + CRLF 
	cQuery += "   AND SD2.D2_VALINS  <> 0 " + CRLF 
	cQuery += "   AND SD2.D2_ALIQINS <> 0 " + CRLF 
	cQuery += "   AND SFT.FT_EMISSAO >= '"+DTOS(dDtini)+"' " + CRLF 
	cQuery += "   AND SFT.FT_EMISSAO <=  '"+DTOS(dDtfim)+"' " + CRLF 
	cQuery += "   AND SFT.FT_DTCANC = ' '" + CRLF
	cQuery += "   AND SA1.A1_PESSOA = 'J'" + CRLF
	cQuery += "   AND SA1.A1_RECINSS = 'S'" + CRLF
	cQuery += "   AND SFT.D_E_L_E_T_ = ' ' " + CRLF  
	cQuery += "   AND SF3.D_E_L_E_T_ = ' ' " + CRLF 
	cQuery += "   AND SD2.D_E_L_E_T_ = ' ' " + CRLF 
	cQuery += "   GROUP BY SF3.R_E_C_N_O_,F3_NFISCAL, F3_FILIAL, F3_ENTRADA, F3_EMISSAO, F3_SERIE, F3_CLIEFOR, F3_LOJA,A1_CGC, A1_NOME,A1_END, A1_COD_MUN ,A1_EST, F3_VALCONT, F3_TIPO, FT_TIPOMOV,F3_CODISS" + CRLF 

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T. , "TOPCONN" , TCGenQry(,,cQuery) , 'TMP154' , .F. , .T. )

	While TMP154-> ( !Eof())

		DbSelectArea("SFT")
		SFT->(DBSETORDER(2))
		SFT->(DBGOTO(TMP154->RECNOSF3))

		nNumNF := cValToChar( TMP154-> F3_NFISCAL)

		cSerie := Alltrim( TMP154-> F3_SERIE)	

		cCliFor := TMP154-> F3_CLIEFOR

		If ( TMP154 -> FT_TIPOMOV) == 'E' 

			cCF2 := "F"+cCliFor			
		Else
			cCF2 := "C"+cCliFor

		Endif

		cLojaCF := TMP154-> F3_LOJA

		dDataE := TMP154-> F3_EMISSAO	

		cNature := TMP154-> FT_TIPOMOV

		If ( TMP154 -> FT_TIPOMOV) == 'E'
			cNature := '0'
		Else
			cNature := '1'
		Endif		  

		nValctb:= cValToChar( TMP154-> F3_VALCONT)

		nBasIns:= cValToChar( TMP154->BASE_INSS)

		nValIns:= cValToChar( TMP154->VLR_INSS)

		cCodISS:= Alltrim( TMP154-> F3_CODISS)

		cRazaoS:= Alltrim( TMP154-> NOME) 

		cCgcCpf:= cValToChar( TMP154-> CNPJ)

		cLograd:= Alltrim( TMP154-> _END)

		cCodMun:= cValToChar( TMP154-> CODMUN)

		cUf:= ( TMP154 -> EST)

		POSICIONE("SA2",1, xFilial("SA2") + TMP154->F3_CLIEFOR + TMP154->F3_LOJA , "A2_CPRB")

		If ( TMP154 -> FT_TIPOMOV) == 'E' .And. SA2-> A2_CPRB == "1"

			cCprb:= "1"

		Else

			cCprb:= "0"

		Endif

		POSICIONE("CDN",1, xFilial("CDN") + TMP154->F3_CODISS, "CDN_TPSERV")

		cCodSer := Alltrim(CDN->CDN_TPSERV) 

		Do Case

			Case cCodSer == "01" 
			cTpServ := "100000001"

			Case cCodSer == "02" 
			cTpServ := "100000002"

			Case cCodSer == "03" 
			cTpServ := "100000003"

			Case cCodSer == "04" 
			cTpServ := "100000004"

			Case cCodSer == "05" 
			cTpServ := "100000005"

			Case cCodSer == "06" 
			cTpServ := "100000006"

			Case cCodSer == "07" 
			cTpServ := "100000007"

			Case cCodSer == "08" 
			cTpServ := "100000008"

			Case cCodSer == "09" 
			cTpServ := "100000009"

			Case cCodSer == "10" 
			cTpServ := "100000010"

			Case cCodSer == "11" 
			cTpServ := "100000011"

			Case cCodSer == "12" 
			cTpServ := "100000012"

			Case cCodSer == "13" 
			cTpServ := "100000013"

			Case cCodSer == "14" 
			cTpServ := "100000014"

			Case cCodSer == "15" 
			cTpServ := "100000015"

			Case cCodSer == "16" 
			cTpServ := "100000016"

			Case cCodSer == "17" 
			cTpServ := "100000017"

			Case cCodSer == "18" 
			cTpServ := "100000018"

			Case cCodSer == "19" 
			cTpServ := "100000019"

			Case cCodSer == "20" 
			cTpServ := "100000020"

			Case cCodSer == "21" 
			cTpServ := "100000021"

			Case cCodSer == "22" 
			cTpServ := "100000022"

			Case cCodSer == "23" 
			cTpServ := "100000023"

			Case cCodSer == "24" 
			cTpServ := "100000024"

			Case cCodSer == "25" 
			cTpServ := "100000025"

			Case cCodSer == "26" 
			cTpServ := "100000026"

			Case cCodSer == "27" 
			cTpServ := "100000027"

			Case cCodSer == "28" 
			cTpServ := "100000028"

			Case cCodSer == "29" 
			cTpServ := "100000029"

			Case cCodSer == "30" 
			cTpServ := "100000030"

			Case cCodSer == "31" 
			cTpServ := "100000031" 

		EndCase

		TMP154-> ( DBSKIP())

		Aadd( aReg003, "|T003|"+cCF2+cLojaCF+"|"+cRazaoS+"|01058|"+cCgcCpf+"|||"+cCodMun+"||03|"+cLograd+"|||||"+cUf+"|||||||20180101|2|||||||||||||||||"+cCprb+"|||2||")
		Aadd( aReg154, "|T154|"+ Alltrim(nNumNF) +"|"+cSerie+"|"+cCF2+cLojaCF+"|"+ dDataE+"|"+cNature+"||||||"+ nValctb+"|||||||||0,0|0,0|0,0|0,0|0,0|0,0|0,0|0,0|0,0|0,0||||0,0||||3|"+cCodISS+"|||||||")
		Aadd( aR154AA, "|T154AA|"+ cTpServ + "|"+ nBasIns+"|"+ nValIns+"||||||||||||")
		Aadd( aR154AB, "|T154AB|1|" + nValctb + "|")

		nArquivo := fcreate(cDir + cNomeArq, FC_NORMAL)

		if ferror() # 0
			msgalert ("ERRO AO CRIAR O ARQUIVO, ERRO: " + str(ferror()))
			lFalha := .T.
		else

			cLin := "|T001"+"|"
			cLin += cEmpc + cFcorr + "|"+"#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|#NAOGRAVAR#|" + CRLF
			cLin += "|T001AA"+"|"+cUfFil+"|"+ Alltrim(cIeFil) +"||"+ CRLF
			cLin += "|T001AN|53113791000122|TOTVS S.A|MARCELO EDUARDO SANTANNA CONSENTINO|1140040015|marceloc@totvs.com.br|"+ CRLF

			If fWrite(nArquivo,cLin,Len(cLin)) != Len(cLin)

			Endif  

			for nLinha := 1 to len(aReg003)  
				for nLinha := 1 to len(aReg154)
					For nLinha := 1 to len(aR154AA)
						For nLinha := 1 to len(aR154AB)
							fwrite(nArquivo, aReg003[ nLinha] + chr(13) + chr(10))
							fwrite(nArquivo, aReg154[ nLinha] + chr(13) + chr(10))			
							fwrite(nArquivo, aR154AA[ nLinha] + chr(13) + chr(10))
							fwrite(nArquivo, aR154AB[ nLinha] + chr(13) + chr(10))										
							if ferror() # 0
								msgalert ("ERRO GRAVANDO ARQUIVO, ERRO: " + str(ferror()))
								lFalha := .T.
							Endif
						Next
					Next
				Next
			Next
		Endif
		fclose ( nArquivo)

	Enddo

	TMP154-> ( dbCloseArea())

Return
