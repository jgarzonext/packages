CREATE OR REPLACE PACKAGE BODY "PAC_FINANCIERA" AS
   /******************************************************************************
      NOMBRE:      PAC_FINANCIERA
      PROPSITO:   Package financira para las funciones de Cross - ficha financiera

      REVISIONES:
      Ver        Fecha        Autor             Descripcin
      ---------  ----------  ---------------  ------------------------------------
      1.0        08/06/2016   ERH              1.0 0018790: CONF001 - Creacin.
      2.0        06/12/2018   JLTS             2.0 CP0390M_SYS_PERS - JLTS - 20181206 -- Se ajustan algunas condiciones
    3.0        28/12/2018   ACL              3.0 CP0455M_SYS_PERS - Se modifica la funcin f_grabar_endeuda
      4.0        11/01/2019   JLTS             4.0 Ajuste de las condicionales de este factor c
      5.0        24/02/2019   JLTS             5.0 TCS_9998 IAXIS-2490 Ajustar las funcinoes f_factor_a y f_factor_p incluyendo los datos de
                                                   Convivencia apuntando a la BBDD de OSIRIS
	 6.0		27/02/2019	 KRISHNAKANT	    6.0 IAXIS-2120 - Declaracion de renta

    7.0        01/03/2019   AABC             7.0 IAXIS-2036 Informacion Financiera no duplicidad fecha financiera
    8.0	       01/03/2019	CES		             8.0 TCS-1554 Convivencia Osiris
    9.0        10/03/2019   JLTS             890 TCS_11;IAXIS-2119 - Creacin de las funciones F_GRABAR_GENERAL_DET, F_GET_GENERAL_PERSONA_DET
	                                         y F_DEL_FIN_GENERAL_DET, adicionalmente se modificac F_GRABAR_GENERAL.
	10.0        17/04/2019   CES                 9.0 IAXIS-3671: Ajuste convivencia cupos para personas naturales	
   11.0        15/04/2019   JLTS             11.0 IAXIS-3673 Validacin de la ecuacin patrimonial
   12.0        26/04/2019      JLTS           12.0 Se ajusta la función f_grabar_endeuda incluyendo la excepcion en el INSERT   
   13.0        21/05/2019   JLTS             13.0 IAXIS-4146. Se ajusta la consulta de la funcion f_get_endeuda
   14.0        23/05/20109     JLTS           14.0 IAXIS-4242 Se ajusta la tabla y la consulta de la funcion f_factor_r  
   15.0        31/05/2019 Krishnakant   15.0 IAXIS-3674:AMPLIACIN DE LOS CAMPOS DE CONCEPTOS
   16.0        01/08/2019   PranayK		16.0 IAXIS-4945:Campo Patrimonio liquido
   17.0        19/02/2020   JLTS              17.0 IAXIS-2099: Se crea la función f_grab_agenda_no_inf_fin
   18.0		   18/03/2020	SP			  18.0 Cambios de IAXIS-13044
   ******************************************************************************/

   /******************************************************************************
     NOMBRE:     F_GRABAR_GENERAL
     PROPSITO:  Funcion que almacena los datos generales de la ficha financiera.

     PARAMETROS:

          return            : 0 -> Todo correcto
                              1 -> Se ha producido un error

   *****************************************************************************/
   FUNCTION f_grabar_general(
      psperson IN NUMBER,
     psfinanci IN NUMBER,
        pcmodo IN VARCHAR2,
     ptdescrip IN VARCHAR2,
      pfccomer IN DATE,
     pcfotorut IN NUMBER,
         pfrut IN DATE,
      pttitulo IN VARCHAR2,
     pcfotoced IN NUMBER,
     pfexpiced IN DATE,
        pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      ptinfoad IN VARCHAR2,
        pcciiu IN NUMBER,
     pctipsoci IN NUMBER,
      pcestsoc IN NUMBER,
      ptobjsoc IN VARCHAR2,
      ptexperi IN VARCHAR2,
      pfconsti IN DATE,
      ptvigenc IN VARCHAR2,
      mensajes IN OUT T_IAX_MENSAJES )

      RETURN NUMBER is

      v_retorno  NUMBER(1) := 0;
      v_existe   NUMBER(1) := 0;
      vnumerr    NUMBER;
      vobjectname VARCHAR2(100) := 'pac_financiera.f_grabar_general';
      vsfinanci NUMBER;
      -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019
      v_exists_sperson_fin NUMBER := 0;
      -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019
       BEGIN

        SELECT count(*)
          INTO v_existe
          FROM FIN_GENERAL
         WHERE sfinanci = psfinanci;

        -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019 - Se garantiza que solo exista un dato de persona en la tabla FIN_GENERAL
        SELECT count(1)
          INTO v_exists_sperson_fin
          FROM FIN_GENERAL f
         WHERE f.sperson = psperson;
        -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019
        -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019 - Se adiciona la condicin v_exists_sperson_fin = 0
        IF v_existe = 0 AND v_exists_sperson_fin = 0 THEN
          -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019
          --JAAB 22/03/2018 INICIO
          --Para migracin se debe respetar el psfinanci que recibe
          IF nvl(psfinanci, 0) <> 0 THEN
            vsfinanci := psfinanci;
          ELSE
            vsfinanci := sfinanci.nextval;
          END IF;
          --JAAB 22/03/2018 INICIO

          INSERT INTO FIN_GENERAL
                      (sperson, sfinanci, tdescrip, fccomer, cfotorut, frut,
                       ttitulo, cfotoced, fexpiced, cpais, cprovin, cpoblac,
                       tinfoad, cciiu, ctipsoci, cestsoc, tobjsoc, texperi,
                       fconsti, tvigenc)
               VALUES (psperson, vsfinanci, ptdescrip, pfccomer, pcfotorut, pfrut,
                       pttitulo, pcfotoced, pfexpiced, pcpais, pcprovin, pcpoblac,
                       ptinfoad, pcciiu, pctipsoci, pcestsoc, ptobjsoc, ptexperi,
                       pfconsti, ptvigenc);
					      
        END IF;

        -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019 - Se adiciona la condicin v_exists_sperson_fin = 0
        IF v_existe = 1 OR v_exists_sperson_fin > 0 THEN
        -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019
         UPDATE FIN_GENERAL
            SET tdescrip = ptdescrip,
                fccomer = pfccomer,
               cfotorut = pcfotorut,
                   frut = pfrut,
                ttitulo = pttitulo,
               cfotoced = pcfotoced,
               fexpiced = pfexpiced,
                  cpais = pcpais,
                cprovin = pcprovin,
                cpoblac = pcpoblac,
                tinfoad = ptinfoad,
                  cciiu = pcciiu,
               ctipsoci = pctipsoci,
                cestsoc = pcestsoc,
                tobjsoc = ptobjsoc,
                texperi = ptexperi,
               -- fconsti = pfconsti,
                tvigenc = ptvigenc
          WHERE sfinanci = psfinanci
            AND sperson  = psperson; -- TCS_11;IAXIS-2119 - JLTS - Se adiciona la condicion del sperson

        END IF;
        --COMMIT;
        RETURN 0;
      EXCEPTION
        WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor', SQLERRM || ' ' || SQLCODE);
           RETURN SQLCODE;
      END f_grabar_general;

   -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019 - Creacin de la funcion f_grabar_general_det
   /******************************************************************************
     NOMBRE:     F_GRABAR_GENERAL_DET
     PROPSITO:  Funcion que almacena los datos generales de la ficha financiera.
                     con sus movimientos
     PARAMETROS:

          return            : 0 -> Todo correcto
                              1 -> Se ha producido un error

   *****************************************************************************/
   FUNCTION f_grabar_general_det(
     psfinanci IN NUMBER,
     pnmovimi  IN NUMBER,
        pcmodo IN VARCHAR2,
     ptdescrip IN VARCHAR2,
      pfccomer IN DATE,
     pcfotorut IN NUMBER,
         pfrut IN DATE,
      pttitulo IN VARCHAR2,
     pcfotoced IN NUMBER,
     pfexpiced IN DATE,
        pcpais IN NUMBER,
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      ptinfoad IN VARCHAR2,
        pcciiu IN NUMBER,
     pctipsoci IN NUMBER,
      pcestsoc IN NUMBER,
      ptobjsoc IN VARCHAR2,
      ptexperi IN VARCHAR2,
      pfconsti IN DATE,
      ptvigenc IN VARCHAR2,
      mensajes IN OUT T_IAX_MENSAJES )

      RETURN NUMBER is

      v_retorno  NUMBER(1) := 0;
      v_existe   NUMBER(1) := 0;
      vnumerr    NUMBER;
      vobjectname VARCHAR2(100) := 'pac_financiera.f_grabar_general_det';
      v_frut VARCHAR2(10) := NVL(TO_CHAR(pfrut,'DD/MM/YYYY'),'01/01/1900');
      v_fccomer VARCHAR2(10) := NVL(TO_CHAR(pfccomer,'DD/MM/YYYY'),'01/01/1900');
      v_max_nmovimi NUMBER := 0;
      PROCEDURE p_upd_fin_general IS
      BEGIN
        UPDATE  FIN_GENERAL f
              SET tdescrip = ptdescrip,
                fccomer = pfccomer,
               cfotorut = pcfotorut,
                   frut = pfrut,
                ttitulo = pttitulo,
               cfotoced = pcfotoced,
               fexpiced = pfexpiced,
                  cpais = pcpais,
                cprovin = pcprovin,
                cpoblac = pcpoblac,
                tinfoad = ptinfoad,
                  cciiu = pcciiu,
               ctipsoci = pctipsoci,
                cestsoc = pcestsoc,
                tobjsoc = ptobjsoc,
                texperi = ptexperi,
                fconsti = pfconsti,
                tvigenc = ptvigenc
             WHERE f.sfinanci = psfinanci;
      END p_upd_fin_general;
       BEGIN
        SELECT count(*)
          INTO v_existe
          FROM FIN_GENERAL_DET F
         WHERE f.sfinanci = psfinanci
           AND NVL(TO_CHAR(f.frut,'DD/MM/YYYY'),'01/01/1900') = v_frut
           AND NVL(TO_CHAR(f.fccomer,'DD/MM/YYYY'),'01/01/1900') = v_fccomer
           AND f.nmovimi != NVL(pnmovimi,0); -- Cuando no viene es porque es nulo
        IF v_existe = 0 and pcmodo = 0 THEN

          INSERT INTO FIN_GENERAL_DET
                      (sfinanci, nmovimi,tdescrip, fccomer, cfotorut, frut,
                       ttitulo, cfotoced, fexpiced, cpais, cprovin, cpoblac,
                       tinfoad, cciiu, ctipsoci, cestsoc, tobjsoc, texperi,
                       fconsti, tvigenc)
               VALUES ( psfinanci, SEQ_FIN_GEN_DET.nextval,ptdescrip, pfccomer, pcfotorut, pfrut,
                       pttitulo, pcfotoced, pfexpiced, pcpais, pcprovin, pcpoblac,
                       ptinfoad, pcciiu, pctipsoci, pcestsoc, ptobjsoc, ptexperi,
                       pfconsti, ptvigenc);
          p_upd_fin_general;
        END IF;

        IF v_existe = 0 AND pcmodo = 2 THEN
         select NVL(max(fd.nmovimi),0)
           into v_max_nmovimi
           from fin_general_det fd
          where fd.sfinanci = psfinanci;

          IF v_max_nmovimi != 0 AND  pnmovimi = v_max_nmovimi THEN
            -- aqui
            p_upd_fin_general;
           END IF;
         UPDATE FIN_GENERAL_DET
            SET sfinanci = psfinanci,
               tdescrip = ptdescrip,
                fccomer = pfccomer,
               cfotorut = pcfotorut,
                   frut = pfrut,
                ttitulo = pttitulo,
               cfotoced = pcfotoced,
               fexpiced = pfexpiced,
                  cpais = pcpais,
                cprovin = pcprovin,
                cpoblac = pcpoblac,
                tinfoad = ptinfoad,
                  cciiu = pcciiu,
               ctipsoci = pctipsoci,
                cestsoc = pcestsoc,
                tobjsoc = ptobjsoc,
                texperi = ptexperi,
                fconsti = pfconsti,
                tvigenc = ptvigenc
          WHERE sfinanci = psfinanci
            AND nmovimi  = pnmovimi;
        ELSIF v_existe = 1 AND (pcmodo = 0 OR pcmodo = 2) THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 89906237);
            rollback;
            RETURN 1;
        END IF;
        RETURN 0;
      EXCEPTION
        WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor', SQLERRM || ' ' || SQLCODE);
           RETURN SQLCODE;
      END f_grabar_general_det;
    -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019

   /******************************************************************************
     NOMBRE:     F_GRABAR_RENTA
     PROPSITO:  Funcin que almacena los datos de la declaracin de renta de la ficha financiera por persona.

     PARAMETROS:

          return            : 0 -> Todo correcto
                              1 -> Se ha producido un error

   *****************************************************************************/
      FUNCTION f_grabar_renta(
       psfinanci IN NUMBER,
          pcmodo IN VARCHAR2,
         pfcorte IN DATE,
       pcesvalor IN NUMBER,
      pipatriliq IN NUMBER,
         pirenta IN NUMBER,
        mensajes IN OUT T_IAX_MENSAJES )

      RETURN NUMBER is

      v_retorno  NUMBER(1) := 0;
      v_existe   NUMBER(1) := 0;
      vobjectname VARCHAR2(100) := 'pac_financiera.f_grabar_renta';

       BEGIN

        SELECT count(*)
          INTO v_existe
          FROM FIN_D_RENTA
         WHERE sfinanci = psfinanci
           and   fcorte = pfcorte;


        IF v_existe = 0 THEN
          INSERT INTO FIN_D_RENTA
                      (sfinanci, fcorte, cesvalor, ipatriliq, irenta)
               VALUES (psfinanci, pfcorte, pcesvalor, pipatriliq, pirenta);

        END IF;


        --INI IAXIS-2120  -27/02/2019- Declaracion de renta
        IF v_existe = 1 AND pcmodo = 2 THEN
         UPDATE FIN_D_RENTA
            SET   fcorte = pfcorte,
                cesvalor = pcesvalor,
               ipatriliq = pipatriliq,
                  irenta = pirenta
          WHERE sfinanci = psfinanci
            AND   fcorte = pfcorte;
        ELSIF v_existe = 1 AND pcmodo = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 89906229);
            return 1;
        END IF;
        --FIN IAXIS-2120 -27/02/2019- Declaracion de renta

        --COMMIT;
        RETURN 0;
      EXCEPTION
        WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor', SQLERRM || ' ' || SQLCODE);
           RETURN SQLCODE;
      END f_grabar_renta;


   /******************************************************************************
     NOMBRE:     F_GRABAR_ENDEUDA
     PROPSITO:  Funcin que almacena los datos del endeudamiento financiero de la central de riesgos por persona.

     PARAMETROS:

          return            : 0 -> Todo correcto
                              1 -> Se ha producido un error

   *****************************************************************************/
      FUNCTION f_grabar_endeuda(
        psfinanci IN NUMBER,
       pfconsulta IN DATE,
           pcmodo IN VARCHAR2,
         pcfuente IN NUMBER,
         piminimo IN NUMBER,
         picappag IN NUMBER,
         picapend IN NUMBER,
         piendtot IN NUMBER,
         pncalifa IN NUMBER,
         pncalifb IN NUMBER,
         pncalifc IN NUMBER,
         pncalifd IN NUMBER,
         pncalife IN NUMBER,
         pnconsul IN NUMBER,
          pnscore IN NUMBER,
           pnmora IN NUMBER,
          picupog IN NUMBER,
          picupos IN NUMBER,
           pfcupo IN DATE,
          ptcupor IN VARCHAR2,
        pcrestric IN NUMBER,
     ptconcepc IN CLOB, --IAXIS-3674 Krishnakant 31/05/2019
         ptconceps IN CLOB, --IAXIS-3674 Krishnakant 31/05/2019
         ptcburea IN CLOB,--IAXIS-3674 Krishnakant 31/05/2019
         ptcotros IN CLOB,--IAXIS-3674 Krishnakant 31/05/2019
         mensajes IN OUT T_IAX_MENSAJES )

      RETURN NUMBER is

      v_retorno  NUMBER(1) := 0;
      v_existe   NUMBER(1) := 0;
      vobjectname VARCHAR2(100) := 'pac_financiera.f_grabar_endeuda';
	  PSPERSON VARCHAR2(12); 
	  PCTIPPER NUMBER;
	  /* Cambios de  tarea IAXIS-13044 : start */
	  VPERSON_NUM_ID per_personas.nnumide%type;
	  /* Cambios de  tarea IAXIS-13044 : end */
       BEGIN
        -- Ini CP0455M_SYS_PERS - ACL - 28/12/2018 - Se ajusta condicion
        IF pcmodo IN (1, 2) THEN
        SELECT count(*)
          INTO v_existe
          FROM FIN_ENDEUDAMIENTO
         WHERE  sfinanci = psfinanci
           AND fconsulta = pfconsulta
           AND   cfuente = pcfuente;
        ELSE
      v_existe := 0;
        END IF;
    -- Fin CP0455M_SYS_PERS - ACL - 28/12/2018
        IF v_existe = 0 THEN
-- INI IAXIS-3632 - JLTS - 26/04/2019 - Se adiciona la excepcion
					BEGIN
						INSERT INTO fin_endeudamiento
							(sfinanci, fconsulta, cfuente, iminimo, icappag, icapend, iendtot, ncalifa, ncalifb, ncalifc, ncalifd, ncalife,
							 nconsul, nscore, nmora, icupog, icupos, fcupo, crestric, tconcepc, tconceps, tcburea, tcotros)
						VALUES
							(psfinanci, pfconsulta, pcfuente, piminimo, picappag, picapend, piendtot, pncalifa, pncalifb, pncalifc, pncalifd,
							 pncalife, pnconsul, pnscore, pnmora, picupog, picupos, pfcupo, pcrestric, ptconcepc, ptconceps, ptcburea, ptcotros);
					EXCEPTION
						WHEN dup_val_on_index THEN
							pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 108959);
							RETURN 1;
					END;
					-- FIN IAXIS-3632 - JLTS - 26/04/2019 - Se adiciona la excepcion

        
			--INI-CES-IAXIS-3671
			SELECT SPERSON INTO PSPERSON
			FROM FIN_GENERAL WHERE SFINANCI = psfinanci;

		    SELECT CTIPPER,NNUMIDE
			  INTO PCTIPPER,VPERSON_NUM_ID
			  FROM PER_PERSONAS
			 WHERE SPERSON = PSPERSON;

			IF PCTIPPER='1' THEN --VALIDACIN PARA PERSONA NATURAL
			/* Cambios de  tarea IAXIS-13044 :start */
			   BEGIN                                                                 
				 PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
												   1,
												   'S03502',
												   NULL);
			   EXCEPTION
				WHEN OTHERS
				THEN
				 p_tab_error (f_sysdate,
							  f_user,
							  'PAC_FINANCIERA.f_grabar_endeuda',
							  1,
							  'Error PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
							  SQLERRM
							 );                                                            												  
			   END;
		    /* Cambios de  tarea IAXIS-13044 :end */ 
			END IF;
			--END-CES-IAXIS-3671		
		END IF;


        IF v_existe = 1 THEN
         UPDATE FIN_ENDEUDAMIENTO
            SET fconsulta = pfconsulta,
                 cfuente = pcfuente,
                 iminimo = piminimo,
                 icappag = picappag,
                 icapend = picapend,
                 iendtot = piendtot,
                 ncalifa = pncalifa,
                 ncalifb = pncalifb,
                 ncalifc = pncalifc,
                 ncalifd = pncalifd,
                 ncalife = pncalife,
                 nconsul = pnconsul,
                  nscore = pnscore,
                   nmora = pnmora,
                  icupog = picupog,
                  icupos = picupos,
                   fcupo = pfcupo,
                crestric = pcrestric,
                tconcepc = ptconcepc,
                tconceps = ptconceps,
                 tcburea = ptcburea,
                 tcotros = ptcotros
          WHERE sfinanci = psfinanci
           AND fconsulta = pfconsulta
           AND   cfuente = pcfuente;
        END IF;
		
		--INI-CES-IAXIS-3671
			SELECT SPERSON INTO PSPERSON
			FROM FIN_GENERAL WHERE SFINANCI = psfinanci;

			  SELECT CTIPPER, NNUMIDE
				INTO PCTIPPER, VPERSON_NUM_ID
				FROM PER_PERSONAS
			  WHERE SPERSON = PSPERSON;

			IF PCTIPPER='1' THEN --VALIDACIN PARA PERSONA NATURAL
			/* Cambios de  tarea IAXIS-13044 :start */
				BEGIN                                                                 
				   PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
													 1,
													 'S03502',
													 NULL);
				EXCEPTION
				WHEN OTHERS
				THEN
				 p_tab_error (f_sysdate,
							  f_user,
							  'PAC_FINANCIERA.f_grabar_endeuda',
							  1,
							  'Error PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
							  SQLERRM
							 );                                                            												  
			    END;
			/* Cambios de  tarea IAXIS-13044 :end */ 				
			END IF;
		--END-CES-IAXIS-3671

		
        --COMMIT;
        RETURN 0;
      EXCEPTION
        WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor', SQLERRM || ' ' || SQLCODE);
           RETURN SQLCODE;
      END f_grabar_endeuda;


   /******************************************************************************
     NOMBRE:     F_GRABAR_INDICADOR
     PROPSITO:  Funcin que almacena los datos de indicadores financieros por persona.

     PARAMETROS:

          return            : 0 -> Todo correcto
                              1 -> Se ha producido un error

   *****************************************************************************/
      FUNCTION f_grabar_indicador(
        psfinanci IN NUMBER,
         pnmovimi IN NUMBER,
           pcmodo IN VARCHAR2,
         pimargen IN NUMBER,
        picaptrab IN NUMBER,
         ptrazcor IN VARCHAR2,
         ptprbaci IN VARCHAR2,
        pienduada IN NUMBER,
         pndiacar IN NUMBER,
         pnrotpro IN NUMBER,
         pnrotinv IN NUMBER,
        pndiacicl IN NUMBER,
         pirentab IN NUMBER,
          pioblcp IN NUMBER,
          piobllp IN NUMBER,
        pigastfin IN NUMBER,
          pivalpt IN NUMBER,
        pcesvalor IN NUMBER,
         pcmoneda IN VARCHAR2,
           pfcupo IN DATE,
          picupog IN NUMBER,
          picupos IN NUMBER,
          pfcupos IN DATE,
          ptcupor IN VARCHAR2,
      ptconcepc IN CLOB, --IAXIS-3674 Krishnakant 31/05/2019
         ptconceps IN CLOB, --IAXIS-3674 Krishnakant 31/05/2019
         ptcburea IN CLOB,--IAXIS-3674 Krishnakant 31/05/2019
         ptcotros IN CLOB,--IAXIS-3674 Krishnakant 31/05/2019
         pcmoncam IN VARCHAR2,
         pncapfin IN NUMBER,
        mensajes IN OUT T_IAX_MENSAJES )

      RETURN NUMBER is

      v_retorno  NUMBER(1) := 0;
      v_existe   NUMBER(1) := 0;
      v_feesfin  DATE;
      vobjectname VARCHAR2(100) := 'pac_financiera.f_grabar_indicador';
      vnmovimi  NUMBER;
      PSPERSON VARCHAR2(12);
	  /* Cambios de  tarea IAXIS-13044 : start */
	  VPERSON_NUM_ID per_personas.nnumide%type;
	  /* Cambios de  tarea IAXIS-13044 : end */
       BEGIN
        -- Inicio IAXIS-2036 Informacion Financiera no duplicidad fecha financiera
        /*SELECT count(*)
          INTO v_existe
          FROM FIN_INDICADORES
         WHERE sfinanci = psfinanci
           AND  nmovimi = pnmovimi;*/
        -- Fin IAXIS-2036 Informacion Financiera no duplicidad fecha financiera

        BEGIN
            SELECT FP.FVALPAR
                INTO v_feesfin
                FROM FIN_PARAMETROS FP
               WHERE FP.SFINANCI = psfinanci
                 AND FP.NMOVIMI = pnmovimi
                 AND CPARAM = 'FECHA_EST_FIN';
        EXCEPTION WHEN OTHERS THEN
            p_tab_error(f_sysdate, USER, vobjectname, 0, 'Error leyendo fin_parametros FECHA_EST_FIN', SQLERRM || ' ' || SQLCODE);
            RETURN SQLCODE;
        END;
         -- Inicio IAXIS-2036 Informacion Financiera no duplicidad fecha financiera
         SELECT count(*)
          INTO v_existe
          FROM FIN_INDICADORES F
         WHERE F.sfinanci = psfinanci
           AND TRUNC(F.FINDICAD) = TRUNC(v_feesfin);
         -- Fin IAXIS-2036 Informacion Financiera no duplicidad fecha financiera

                  --JAAB 22/03/2018 INICIO
          --Para migracin se debe respetar el pnmovimi que recibe
          IF nvl(pnmovimi, 0) <> 0 THEN
            vnmovimi := pnmovimi;
          ELSE
            vnmovimi := nmovimi.nextval;
          END IF;
          --JAAB 22/03/2018 INICIO





        IF v_existe = 0 THEN
          INSERT INTO FIN_INDICADORES
                      (sfinanci, nmovimi, findicad, imargen, icaptrab,
                        trazcor, tprbaci, ienduada, ndiacar, nrotpro,
                        nrotinv, ndiacicl, irentab, ioblcp, iobllp,
                       igastfin, ivalpt, cesvalor, cmoneda, fcupo,
                         icupog, icupos, fcupos, tcupor, tconcepc,
                       tconceps, tcburea, tcotros, cmoncam, ncapfin)
               VALUES (psfinanci, vnmovimi, v_feesfin, pimargen, picaptrab,
                        ptrazcor, ptprbaci, pienduada, pndiacar, pnrotpro,
                        pnrotinv, pndiacicl, pirentab, pioblcp, piobllp,
                       pigastfin, pivalpt, pcesvalor, pcmoneda, pfcupo,
                         picupog, picupos, pfcupos, ptcupor, ptconcepc,
                       ptconceps, ptcburea, ptcotros, pcmoncam, pncapfin);

            IF nvl(pnmovimi, 0) = 0 THEN
                UPDATE FIN_PARAMETROS
                   SET  nmovimi = (SELECT MAX(NMOVIMI) FROM FIN_INDICADORES)
                 WHERE sfinanci = psfinanci
                   AND  nmovimi = 0;
            END IF;

			--INI 1554 CESS
			IF picupog IS NOT NULL AND picupos IS NOT NULL THEN
			SELECT SPERSON INTO
			PSPERSON
			FROM FIN_GENERAL WHERE SFINANCI = psfinanci;

			/* Cambios de Swapnil para Convivencia :start */
			    BEGIN
				 SELECT PP.NNUMIDE
				   INTO VPERSON_NUM_ID
				   FROM PER_PERSONAS PP
				  WHERE PP.SPERSON = PSPERSON;
																  
				 PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
												   1,
												   'S03502',
												   NULL);
				EXCEPTION
				WHEN OTHERS
				THEN
				 p_tab_error (f_sysdate,
							  f_user,
							  'PAC_FINANCIERA.f_grabar_indicador',
							  1,
							  'Error PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
							  SQLERRM
							 );                                                            												  
			    END;			   
		    /* Cambios de Swapnil para Convivencia :end */ 	   
			END IF;
			--END 1554 CESS

        END IF;

        -- Inicio IAXIS-2036 Informacion Financiera no duplicidad fecha financiera
        IF v_existe = 1  AND pcmodo = 2 THEN
         UPDATE FIN_INDICADORES
            SET findicad = v_feesfin,
                 imargen = pimargen,
                icaptrab = picaptrab,
                 trazcor = ptrazcor,
                 tprbaci = ptprbaci,
                ienduada = pienduada,
                 ndiacar = pndiacar,
                 nrotpro = pnrotpro,
                 nrotinv = pnrotinv,
                ndiacicl = pndiacicl,
                 irentab = pirentab,
                  ioblcp = pioblcp,
                  iobllp = piobllp,
                igastfin = pigastfin,
                  ivalpt = pivalpt,
                cesvalor = pcesvalor,
                 cmoneda = pcmoneda,
                   fcupo = pfcupo,
                  icupog = picupog,
                  icupos = picupos,
                  fcupos = pfcupos,
                  tcupor = ptcupor,
                tconcepc = ptconcepc,
                tconceps = ptconceps,
                 tcburea = ptcburea,
                 tcotros = ptcotros,
                 cmoncam = pcmoncam,
                 ncapfin = pncapfin
          WHERE sfinanci = psfinanci
            AND  nmovimi = pnmovimi;

			--INI 1554 CESS
			IF picupog IS NOT NULL AND picupos IS NOT NULL THEN
			SELECT SPERSON INTO
			PSPERSON
			FROM FIN_GENERAL WHERE SFINANCI = psfinanci;

		/* Cambios de Swapnil para Convivencia :start */
		   BEGIN
			 SELECT PP.NNUMIDE
			   INTO VPERSON_NUM_ID
			   FROM PER_PERSONAS PP
			  WHERE PP.SPERSON = PSPERSON;
															  
			 PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
											   1,
											   'S03502',
											   NULL);
			EXCEPTION
				WHEN OTHERS
				THEN
				 p_tab_error (f_sysdate,
							  f_user,
							  'PAC_FINANCIERA.f_grabar_indicador',
							  1,
							  'Error PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
							  SQLERRM
							 );                                                            												  
			    END;		   
        /* Cambios de Swapnil para Convivencia :end */ 
	   
			END IF;
			--END 1554 CESS

        ELSIF v_existe = 1 AND pcmodo = 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 89906231);
            RETURN 1;
        END IF;
        -- Fin IAXIS-2036 Informacion Financiera no duplicidad fecha financiera
        --COMMIT;
        RETURN 0;
      EXCEPTION
        WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor', SQLERRM || ' ' || SQLCODE);
           RETURN SQLCODE;
      END f_grabar_indicador;


   /******************************************************************************
     NOMBRE:     F_GRABAR_DOC
     PROPSITO:  Funcin que almacena los documentos asociados a la ficha financiera.

     PARAMETROS:

          return            : 0 -> Todo correcto
                              1 -> Se ha producido un error

   *****************************************************************************/
      FUNCTION f_grabar_doc(
       psfinanci IN NUMBER,
          pcmodo IN VARCHAR2,
        pnmovimi IN NUMBER,
       piddocgdx IN NUMBER,
         ptobser IN VARCHAR2,
        mensajes IN OUT T_IAX_MENSAJES )

      RETURN NUMBER is

      v_retorno  NUMBER(1) := 0;
      v_existe   NUMBER(1) := 0;
      vobjectname VARCHAR2(100) := 'pac_financiera.f_grabar_doc';

       BEGIN

        SELECT count(*)
          INTO v_existe
          FROM FIN_DOCUMENTOS
         WHERE sfinanci = psfinanci;


        IF v_existe = 0 THEN
          INSERT INTO FIN_DOCUMENTOS
                      (sfinanci, nmovimi, iddocgdx, tobser)
               VALUES (psfinanci, pnmovimi, piddocgdx, ptobser);
        END IF;


        IF v_existe = 1 THEN
         UPDATE FIN_DOCUMENTOS
            SET  sfinanci = psfinanci,
                  nmovimi = pnmovimi,
                 iddocgdx = piddocgdx,
                   tobser = ptobser
          WHERE sfinanci = psfinanci;
        END IF;
        --COMMIT;
        RETURN 0;
      EXCEPTION
        WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor', SQLERRM || ' ' || SQLCODE);
           RETURN SQLCODE;
      END f_grabar_doc;
     -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019
    /**********************************************************************
      FUNCTION F_GET_GENERAL_PERSONA_DET
      Funcin que retorna los datos generales de la ficha financiera
      Param IN  psperson  : sperson
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_general_persona_det(
        psperson IN NUMBER,
        pnmovimi IN NUMBER DEFAULT NULL
          )
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_financiera.f_get_general_persona';
      vparam         VARCHAR2(500) := 'parmetros - psperson: ' || psperson;
      vpasexec       NUMBER := 1;

          sperrep VARCHAR2(500);

       BEGIN
          OPEN v_cursor FOR
               SELECT d.sperson, g.nmovimi,g.sfinanci, g.tdescrip, TO_DATE(TO_CHAR(g.fccomer,'DD/MM/YYYY'),'DD/MM/YYYY') fccomer,
                      g.cfotorut, TO_DATE(TO_CHAR(g.frut,'DD/MM/YYYY'),'DD/MM/YYYY') frut, g.ttitulo, g.cfotoced, TO_DATE(TO_CHAR(g.fexpiced,'DD/MM/YYYY'),'DD/MM/YYYY') fexpiced,
                      g.cpais, g.cprovin, g.cpoblac, g.tinfoad, g.cciiu,
                      g.ctipsoci, g.cestsoc, g.tobjsoc, g.texperi,
                      TO_DATE(TO_CHAR(g.fconsti,'DD/MM/YYYY'),'DD/MM/YYYY') fconsti,
                       g.tvigenc, (SELECT pp.TAPELLI1
                                               FROM PER_DETPER pp
                                              WHERE SPERSON = (select pr.SPERSON_REL
                                                                 from PER_PERSONAS_REL pr
                                                                where pr.SPERSON = psperson
                                                                  and pr.CTIPPER_REL = '1')
                                            ) AS SPERREP
                 FROM fin_general_det g,fin_general d
                WHERE g.sfinanci = d.sfinanci
                  and d.sperson = psperson
                  AND g.nmovimi = NVL(pnmovimi,g.nmovimi)
                  order by g.nmovimi asc;
          RETURN v_cursor;
       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                         SQLERRM || ' ' || SQLCODE);

             IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
             END IF;

             RETURN v_cursor;
       END f_get_general_persona_det;
       -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019

    /**********************************************************************
      FUNCTION F_GET_GENERAL_PERSONA
      Funcin que retorna los datos generales de la ficha financiera
      Param IN  psperson  : sperson
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_general_persona(
        psperson IN NUMBER
          )
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_financiera.f_get_general_persona';
      vparam         VARCHAR2(500) := 'parmetros - psperson: ' || psperson;
      vpasexec       NUMBER := 1;

          sperrep VARCHAR2(500);

       BEGIN
          OPEN v_cursor FOR
               SELECT g.sperson, g.sfinanci, g.tdescrip, g.fccomer,
                      g.cfotorut, g.frut, g.ttitulo, g.cfotoced, g.fexpiced,
                      g.cpais, g.cprovin, g.cpoblac, g.tinfoad, g.cciiu,
                      g.ctipsoci, g.cestsoc, g.tobjsoc, g.texperi,
                      g.fconsti, g.tvigenc, (SELECT pp.TAPELLI1
                                               FROM PER_DETPER pp
                                              WHERE SPERSON = (select pr.SPERSON_REL
                                                                 from PER_PERSONAS_REL pr
                                                                where pr.SPERSON = psperson
                                                                  and pr.CTIPPER_REL = '1')
                                            ) AS SPERREP
                 FROM fin_general g
                WHERE g.sperson = psperson;



              /*
               SELECT pp.* INTO v_per_personas
                 FROM PER_PERSONAS pp
                WHERE SPERSON = (select pr.SPERSON_REL
                                   from PER_PERSONAS_REL pr
                                  where pr.SPERSON = (SELECT g.sperson
                                                        FROM fin_general g
                                                       WHERE g.sfinanci = psfinanci)
                                    and pr.CTIPPER_REL = '1');

              */
          RETURN v_cursor;
       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                         SQLERRM || ' ' || SQLCODE);

             IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
             END IF;

             RETURN v_cursor;
       END f_get_general_persona;




    /**********************************************************************
      FUNCTION F_GET_GENERAL
      Funcin que retorna los datos generales de la ficha financiera
      Param IN  psfinanci  : sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_general(
        psfinanci IN NUMBER
          )
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_financiera.f_get_general';
      vparam         VARCHAR2(500) := 'parmetros - psfinanci: ' || psfinanci;
      vpasexec       NUMBER := 1;

             sperrep  VARCHAR2(500);
          spersonAux  NUMBER(10,0);

       BEGIN
          OPEN v_cursor FOR

                SELECT g.sperson, g.sfinanci, g.tdescrip, g.fccomer,
                      g.cfotorut, g.frut, g.ttitulo, g.cfotoced, g.fexpiced,
                      g.cpais, g.cprovin, g.cpoblac, g.tinfoad, g.cciiu,
                      g.ctipsoci, g.cestsoc, g.tobjsoc, g.texperi,
                      g.fconsti, g.tvigenc
                 FROM fin_general g
                WHERE g.sfinanci = psfinanci;

                SELECT fg.sperson
                 INTO spersonAux
                 FROM fin_general fg
                WHERE fg.sfinanci = psfinanci;

               SELECT pp.TAPELLI1 INTO sperrep
                 FROM PER_DETPER pp
                WHERE SPERSON = (select pr.SPERSON_REL
                                   from PER_PERSONAS_REL pr
                                  where pr.SPERSON = spersonAux
                                    and pr.CTIPPER_REL = '1');

              /*
               SELECT pp.* INTO v_per_personas
                 FROM PER_PERSONAS pp
                WHERE SPERSON = (select pr.SPERSON_REL
                                   from PER_PERSONAS_REL pr
                                  where pr.SPERSON = (SELECT g.sperson
                                                        FROM fin_general g
                                                       WHERE g.sfinanci = psfinanci)
                                    and pr.CTIPPER_REL = '1');

              */
          RETURN v_cursor;
       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                         SQLERRM || ' ' || SQLCODE);

             IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
             END IF;

             RETURN v_cursor;
       END f_get_general;


    /**********************************************************************
      FUNCTION F_GET_RENTA
      Funcin que retorna los datos de la declaracin de renta de la ficha financiera.
      Param IN  psfinanci: sfinanci
      Param IN DATE DEFAULT NULL pfrenta: frenta fcorte
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_renta(
        psfinanci IN NUMBER,
          pfrenta IN DATE DEFAULT NULL)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_financiera.f_get_renta';
      vparam         VARCHAR2(500) := 'parmetros - psfinanci: ' || psfinanci || ' pfrenta: ' || pfrenta;
      vpasexec       NUMBER := 1;
       BEGIN
          OPEN v_cursor FOR
               SELECT r.sfinanci, r.fcorte, r.cesvalor, r.ipatriliq, r.irenta, (SELECT  dtv.TATRIBU
                                                                                  FROM  DETVALORES  dtv
                                                                                 WHERE  dtv.CVALOR =  8001075
                                                                                   and  dtv.CIDIOMA = pac_md_common.f_get_cxtidioma
                                                                                   and  dtv.CATRIBU = r.cesvalor
                                                                               ) AS TESVALOR
                 FROM fin_d_renta r
                WHERE r.sfinanci = psfinanci
                 AND r.fcorte = nvl(pfrenta,r.fcorte);
          RETURN v_cursor;
       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                         SQLERRM || ' ' || SQLCODE);

             IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
             END IF;

             RETURN v_cursor;
       END f_get_renta;


    /**********************************************************************
      FUNCTION F_GET_ENDEUDA
      Funcin que retorna los datos de endeudamiento financiero de la ficha financiera
      Param IN  psfinanci: sfinanci
      Param IN DATE DEFAULT NULL pfconsulta: fconsulta
      Param IN NUMBER DEFAULT NULL pcfuente: cfuente
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_endeuda(
       psfinanci IN NUMBER,
      pfconsulta IN DATE DEFAULT NULL,
        pcfuente IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_financiera.f_get_endeuda';
      vparam         VARCHAR2(500) := 'parmetros - psfinanci: ' || psfinanci || ' pfconsulta: ' || pfconsulta || ' pcfuente: ' || pcfuente;
      vpasexec       NUMBER := 1;
      -- INI -IAXIS-4146 -JLTS 21/05/2019. Se incluye el campo tncalries
       BEGIN
          OPEN v_cursor FOR
               SELECT e.sfinanci, e.fconsulta, e.cfuente, e.iminimo, e.icappag,
                      e.icapend, e.iendtot, e.ncalifa, e.ncalifb, e.ncalifc,
                      e.ncalifd, e.ncalife, e.nconsul, e.nscore, e.nmora,
                      e.icupog, e.icupos, e.fcupo, e.crestric, e.tconcepc,
                      e.tconceps, e.tcburea, e.tcotros,ff_desvalorfijo(3000,pac_md_common.f_get_cxtidioma,e.ncalries) tncalries
                 FROM fin_endeudamiento e
                WHERE e.sfinanci = psfinanci
                  AND e.fconsulta = NVL(pfconsulta,e.fconsulta)
                  AND e.cfuente = NVL(pcfuente,e.cfuente);
      -- FIN -IAXIS-4146 -JLTS 21/05/2019. Se incluye el campo tncalries
          RETURN v_cursor;
       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                         SQLERRM || ' ' || SQLCODE);

             IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
             END IF;

             RETURN v_cursor;
       END f_get_endeuda;


    /**********************************************************************
      FUNCTION F_GET_INDICADOR
      Funcin que retorna los datos de indicadores financieros de la ficha financiera
      Param IN  psfinanci: sfinanci
      Param IN NUMBER DEFAULT NULL pnmovimi: nmovimi
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_indicador(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_financiera.f_get_indicador';
      vparam         VARCHAR2(500) := 'parmetros - psfinanci: ' || psfinanci || ' pnmovimi: ' || pnmovimi;
      vpasexec       NUMBER := 1;
       BEGIN
          OPEN v_cursor FOR
               SELECT i.sfinanci, i.nmovimi, i.findicad, i.imargen, i.icaptrab,
                      i.trazcor, i.tprbaci, i.ienduada, i.ndiacar, i.nrotpro,
                      i.nrotinv, i.ndiacicl, i.irentab, i.ioblcp, i.iobllp,
                      i.igastfin, i.ivalpt, i.cesvalor, i.cmoneda, i.fcupo,
                      i.icupog, i.icupos, i.fcupos, i.tcupor, i.tconcepc,
                      i.tconceps, i.tcburea, i.tcotros, i.cmoneda AS CMONORI, i.CMONCAM,
                      i.NCAPFIN,
                      (SELECT TVALPAR FROM DETPARAM WHERE CPARAM = 'FUENTE_INFORMACION'
                       AND CIDIOMA = pac_md_common.f_get_cxtidioma
                       AND CVALPAR = (SELECT FP.NVALPAR FROM FIN_PARAMETROS FP WHERE FP.SFINANCI = i.sfinanci AND FP.NMOVIMI = i.nmovimi AND CPARAM = 'FUENTE_INFORMACION')) AS TFUENTE,
                       (SELECT FP.FVALPAR FROM FIN_PARAMETROS FP WHERE FP.SFINANCI = i.sfinanci AND FP.NMOVIMI = i.nmovimi AND CPARAM = 'FECHA_EST_FIN') AS FEESFIN
                 FROM fin_indicadores i
                WHERE i.sfinanci = psfinanci
                  AND i.nmovimi = NVL(pnmovimi,i.nmovimi);
          RETURN v_cursor;
       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                         SQLERRM || ' ' || SQLCODE);

             IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
             END IF;

             RETURN v_cursor;
       END f_get_indicador;


    /**********************************************************************
      FUNCTION F_GET_DOC
      Funcin que retorna los datos de los documentos asociados de la ficha financiera
      Param IN  psfinanci: sfinanci
      Param IN NUMBER DEFAULT NULL pnmovimi: nmovimi
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
     FUNCTION f_get_doc(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER DEFAULT NULL)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_financiera.f_get_doc';
      vparam         VARCHAR2(500) := 'parmetros - psfinanci: ' || psfinanci || ' pnmovimi: ' || pnmovimi;
      vpasexec       NUMBER := 1;
       BEGIN
          OPEN v_cursor FOR
               SELECT d.sfinanci, d.nmovimi, d.iddocgdx, d.tobser, d.falta
                 FROM fin_documentos d
                WHERE d.sfinanci = psfinanci
                  AND d.nmovimi = pnmovimi;
          RETURN v_cursor;
       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                         SQLERRM || ' ' || SQLCODE);

             IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
             END IF;

             RETURN v_cursor;
       END f_get_doc;


    /**********************************************************************
      FUNCTION F_DEL_RENTA
      Funcin que elimina los datos de la declaracin de renta de la ficha financiera por persona
      Param IN psfinanci: sfinanci
      Param IN pfcorte: fcorte
      Param IN pcesvalor: cesvalor
      Param IN pipatriliq: ipatriliq
      Param IN pirenta: irenta
     **********************************************************************/
      FUNCTION f_del_renta(
       psfinanci IN fin_d_renta.sfinanci%TYPE,
         pfcorte IN fin_d_renta.fcorte%TYPE,
       pcesvalor IN fin_d_renta.cesvalor%TYPE,
      pipatriliq IN fin_d_renta.ipatriliq%TYPE,
         pirenta IN fin_d_renta.irenta%TYPE )
       RETURN NUMBER IS
        vpasexec       NUMBER(8) := 1;
        vparam         VARCHAR2(2000) := 'psfinanci = ' || psfinanci || ' pfcorte = ' || pfcorte || ' pcesvalor: ' || pcesvalor || ' pipatriliq: ' || pipatriliq || ' pirenta: ' || pirenta;
        terror         VARCHAR2(2000);
        vobject        VARCHAR2(200) := 'pac_financiera.f_del_renta';
        num_err        axis_literales.slitera%TYPE := 0;
         BEGIN
            DELETE FROM fin_d_renta
                  WHERE  sfinanci = psfinanci
                    AND    fcorte = pfcorte
                    AND  cesvalor = pcesvalor
                    AND ipatriliq = pipatriliq
                    AND    irenta = pirenta;

            --COMMIT;
            RETURN num_err;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
      END f_del_renta;

      -- INI TCS_11;IAXIS-2119 - JLTS - 10/03/2019
         /**********************************************************************
      FUNCTION F_DEL_FIN_GENERAL_DET
      Funcinn que elimina los datos de endeudamiento financiero de la ficha financiera det
      Param IN psfinanci: sfinanci
      Param IN pfconsulta: fconsulta
      Param IN pcfuente: cfuente
     **********************************************************************/
    FUNCTION f_del_fin_general_det(psfinanci IN fin_general_det.sfinanci%TYPE,
                                   pnmovimi  IN fin_general_det.nmovimi%TYPE,
                                   mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
      vpasexec      NUMBER(8) := 1;
      vparam        VARCHAR2(2000) := 'psfinanci = ' || psfinanci || ' pnmovimi = ' || pnmovimi;
      terror        VARCHAR2(2000);
      vobject       VARCHAR2(200) := 'pac_financiera.f_del_fin_general_del';
      num_err       axis_literales.slitera%TYPE := 0;
      v_contador    NUMBER := 0;
      v_max_nmovimi NUMBER := 0;
      FUNCTION f_max_nmovimi RETURN NUMBER IS
        v_max_nmovimi_aux NUMBER := 0;
      BEGIN
        SELECT nvl(MAX(fd.nmovimi), 0) INTO v_max_nmovimi_aux FROM fin_general_det fd WHERE fd.sfinanci = psfinanci;
        RETURN v_max_nmovimi_aux;
      END f_max_nmovimi;
    BEGIN
      SELECT COUNT(1) INTO v_contador FROM fin_general_det fd WHERE fd.sfinanci = psfinanci;
      IF v_contador > 1 THEN
        v_max_nmovimi := f_max_nmovimi;
        --
        DELETE FROM fin_general_det
         WHERE sfinanci = psfinanci
           AND nmovimi = pnmovimi;
        --
        IF pnmovimi = v_max_nmovimi THEN
          v_max_nmovimi := f_max_nmovimi;
          IF v_max_nmovimi != 0 THEN
            UPDATE (SELECT fg.tdescrip AS old_tdescrip, fg.cfotorut AS old_cfotorut, fg.frut AS old_frut, fg.ttitulo AS old_ttitulo,
                            fg.cfotoced AS old_cfotoced, fg.fexpiced AS old_fexpiced, fg.cpais AS old_cpais,
                            fg.cprovin AS old_cprovin, fg.cpoblac AS old_cpoblac, fg.tinfoad AS old_tinfoad, fg.cciiu AS old_cciiu,
                            fg.ctipsoci AS old_ctipsoci, fg.cestsoc AS old_cestsoc, fg.tobjsoc AS old_tobjsoc,
                            fg.texperi AS old_texperi, fg.fconsti AS old_fconsti, fg.tvigenc AS old_tvigenc,
                            fg.fccomer AS old_fccomer, fgd.tdescrip AS new_tdescrip, fgd.cfotorut AS new_cfotorut,
                            fgd.frut AS new_frut, fgd.ttitulo AS new_ttitulo, fgd.cfotoced AS new_cfotoced,
                            fgd.fexpiced AS new_fexpiced, fgd.cpais AS new_cpais, fgd.cprovin AS new_cprovin,
                            fgd.cpoblac AS new_cpoblac, fgd.tinfoad AS new_tinfoad, fgd.cciiu AS new_cciiu,
                            fgd.ctipsoci AS new_ctipsoci, fgd.cestsoc AS new_cestsoc, fgd.tobjsoc AS new_tobjsoc,
                            fgd.texperi AS new_texperi, fgd.fconsti AS new_fconsti, fgd.tvigenc AS new_tvigenc,
                            fgd.fccomer AS new_fccomer
                       FROM fin_general fg
                      INNER JOIN fin_general_det fgd
                         ON fg.sfinanci = fgd.sfinanci
                      WHERE fg.sfinanci = psfinanci
                        AND fgd.nmovimi = v_max_nmovimi)
               SET old_tdescrip = new_tdescrip, old_cfotorut = new_cfotorut, old_frut = new_frut, old_ttitulo = new_ttitulo,
                   old_cfotoced = new_cfotoced, old_fexpiced = new_fexpiced, old_cpais = new_cpais, old_cprovin = new_cprovin,
                   old_cpoblac = new_cpoblac, old_tinfoad = new_tinfoad, old_cciiu = new_cciiu, old_ctipsoci = new_ctipsoci,
                   old_cestsoc = new_cestsoc, old_tobjsoc = new_tobjsoc, old_texperi = new_texperi, old_fconsti = new_fconsti,
                   old_tvigenc = new_tvigenc, old_fccomer = new_fccomer;
          END IF;
        END IF;
      ELSE
        num_err := 2000089;
        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
        RETURN 1;
      END IF;

      RETURN num_err;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        num_err := 2000088; --Error borrando datos de la tabla FIN_GENERAL_DET
        p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
        RETURN num_err;
    END f_del_fin_general_det;
      -- FIN TCS_11;IAXIS-2119 - JLTS - 10/03/2019
    /**********************************************************************
      FUNCTION F_DEL_ENDEUDA
      Funcin que elimina los datos de endeudamiento financiero de la ficha financiera
      Param IN psfinanci: sfinanci
      Param IN pfconsulta: fconsulta
      Param IN pcfuente: cfuente
     **********************************************************************/
      FUNCTION f_del_endeuda(
        psfinanci IN fin_endeudamiento.sfinanci%TYPE,
       pfconsulta IN fin_endeudamiento.fconsulta%TYPE,
         pcfuente IN fin_endeudamiento.cfuente%TYPE )
       RETURN NUMBER IS
        vpasexec       NUMBER(8) := 1;
        vparam         VARCHAR2(2000) := 'psfinanci = ' || psfinanci || ' pfconsulta = ' || pfconsulta || ' pcfuente: ' || pcfuente;
        terror         VARCHAR2(2000);
        vobject        VARCHAR2(200) := 'pac_financiera.f_del_endeuda';
        num_err        axis_literales.slitera%TYPE := 0;
         BEGIN
            DELETE FROM fin_endeudamiento
                  WHERE  sfinanci = psfinanci
                    AND fconsulta = pfconsulta
                    AND   cfuente = pcfuente;

            --COMMIT;
            RETURN num_err;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_del_endeuda;


    /**********************************************************************
      FUNCTION F_DEL_INDICADOR
      Funcin que elimina los datos de indicadores financieros de la ficha financiera
      Param IN psfinanci: sfinanci
      Param IN pnmovimi: nmovimi
     **********************************************************************/
      FUNCTION f_del_indicador(
        psfinanci IN fin_indicadores.sfinanci%TYPE,
         pnmovimi IN fin_indicadores.nmovimi%TYPE DEFAULT NULL )
       RETURN NUMBER IS
        vpasexec       NUMBER(8) := 1;
        vparam         VARCHAR2(2000) := 'psfinanci = ' || psfinanci || ' pnmovimi = ' || pnmovimi;
        terror         VARCHAR2(2000);
        vobject        VARCHAR2(200) := 'pac_financiera.f_del_indicador';
        num_err        axis_literales.slitera%TYPE := 0;
         BEGIN
            DELETE FROM fin_indicadores
                  WHERE  sfinanci = psfinanci
                    AND   nmovimi = pnmovimi;

            --COMMIT;
            RETURN num_err;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_del_indicador;
     -- INI - IAXIS-3673 - JLTS - 15/04/2019. Validacin de la ecuacin patrimonial
    /**********************************************************************
      FUNCTION F_DEL_PARAMETRO
      Funcin que elimina los datos de indicadores financieros de la ficha financiera
      Param IN psfinanci: sfinanci
      Param IN pnmovimi: nmovimi
     **********************************************************************/
      FUNCTION f_del_parametro(
        psfinanci IN fin_indicadores.sfinanci%TYPE,
         pnmovimi IN fin_indicadores.nmovimi%TYPE DEFAULT NULL )
       RETURN NUMBER IS
        vpasexec       NUMBER(8) := 1;
        vparam         VARCHAR2(2000) := 'psfinanci = ' || psfinanci || ' pnmovimi = ' || pnmovimi;
        terror         VARCHAR2(2000);
        vobject        VARCHAR2(200) := 'pac_financiera.f_del_indicador';
        num_err        axis_literales.slitera%TYPE := 0;
         BEGIN
            DELETE FROM fin_parametros
                  WHERE  sfinanci = psfinanci
                    AND   nmovimi = pnmovimi;

            --COMMIT;
            RETURN num_err;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_del_parametro;
     -- FIN - IAXIS-3673 - JLTS - 15/04/2019. Validacin de la ecuacin patrimonial
     /**********************************************************************
      FUNCTION F_GET_PARCUENTA
      Funcin que retorna los datos de parametros de la ficha financiera
      Param IN  psfinanci: sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_parcuenta(
        psfinanci IN NUMBER )
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_financiera.f_get_parcuenta';
      vparam         VARCHAR2(500) := 'parmetros - psfinanci: ' || psfinanci;
      vpasexec       NUMBER := 1;

       BEGIN
          OPEN v_cursor FOR
               SELECT d.tparam, fp.nvalpar, fp.fvalpar, fp.tvalpar
                 FROM codparam c, desparam d, fin_parametros fp
                WHERE c.cparam = d.cparam
                  and fp.cparam = c.cparam
                  and c.cutili = 11
                  and d.cidioma = pac_md_common.f_get_cxtidioma
                  and fp.sfinanci = psfinanci;

         /* SELECT NULL norden_agr,  null cgrppar, null tgrppar,c.cutili, c.cparam, c.ctipo, d.tparam, cp.cvisible, cp.ctipper,
            (select det.tvalpar from detparam det where det.cparam = c.cparam and det.cidioma = d.cidioma) resp, 1 e, c.norden
            FROM codparam c, desparam d, codparam_per cp
            WHERE c.cutili = 11
            AND d.cparam = c.cparam
            AND cp.cparam = c.cparam
            AND d.cidioma = 8 ORDER BY NVL(C.NORDEN,0);
         */
          RETURN v_cursor;
       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                         SQLERRM || ' ' || SQLCODE);

             IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
             END IF;

             RETURN v_cursor;
       END f_get_parcuenta;


    /******************************************************************************
     NOMBRE:     F_INS_PARCUENTA
     PROPSITO:  Funcin que almacena los datos de los parametros de la ficha financiera.

     PARAMETROS:

          return            : 0 -> Todo correcto
                              1 -> Se ha producido un error

   *****************************************************************************/
      FUNCTION f_ins_parcuenta(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER,
         pcparam IN VARCHAR2,
        pnvalpar IN NUMBER,
        ptvalpar IN VARCHAR2,
        pfvalpar IN DATE,
        mensajes IN OUT T_IAX_MENSAJES )

      RETURN NUMBER is

      v_retorno  NUMBER(1) := 0;
      v_existe   NUMBER(1) := 0;
      vobjectname VARCHAR2(100) := 'pac_financiera.f_ins_parcuenta';

       BEGIN

        SELECT count(*)
          INTO v_existe
          FROM FIN_PARAMETROS
         WHERE sfinanci = psfinanci
           AND nmovimi = pnmovimi
           AND cparam = pcparam;

        IF v_existe = 0 THEN
          INSERT INTO FIN_PARAMETROS
                      (sfinanci, nmovimi, cparam, fvalpar, nvalpar, tvalpar)
               VALUES (psfinanci, pnmovimi, pcparam, pfvalpar, pnvalpar, ptvalpar);

        END IF;


        IF v_existe = 1 THEN
         UPDATE FIN_PARAMETROS
            SET sfinanci = psfinanci,
                  cparam = pcparam,
                 fvalpar = pfvalpar,
                 nvalpar = pnvalpar,
                 tvalpar = ptvalpar
          WHERE sfinanci = psfinanci
            AND  nmovimi = pnmovimi
            AND   cparam = pcparam;
        END IF;

        RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor', SQLERRM || ' ' || SQLCODE);
           RETURN SQLCODE;
      END f_ins_parcuenta;


    /**********************************************************************
      FUNCTION F_CONECTAR_CIFIN
      Funcin que realiza la conexin con cifin
      Firma (Specification):
      Param IN  psperson: psperson
     **********************************************************************/



    /**********************************************************************
      FUNCTION F_EXTRAER_XML_CIFIN
      Funcin que realiza la extraccin de la informacin que nos dio como
      respuesta el WebService de la CIFIN
      Firma (Specification):
      Param IN  psfinanci: psfinanci
      Param IN  pnsinterf: pnsinterf

      -- Pendiente consumo webservice CIFIN y invocar a la funcion
      F_GRABAR_ENDEUDA, enviando como parmetros de entrada dichos campos
      respectivamente y el PSPERSON

     **********************************************************************/
      FUNCTION f_extraer_xml_cifin(
      psfinanci IN NUMBER,
      pnsinterf IN NUMBER )

      RETURN NUMBER IS

      v_respuesta     CLOB;
      v_if02_xml      XMLTYPE;
      v_entity        XMLTYPE;
      v_baseQuestions XMLTYPE;
      v_disclosures   XMLTYPE;

      BEGIN


        SELECT xml_respuesta
          INTO v_respuesta
          FROM int_datos_xml
         WHERE sinterf = pnsinterf;

        IF v_respuesta IS NOT NULL THEN

          v_if02_xml := XMLTYPE.createxml(v_respuesta);

            v_entity := v_if02_xml.EXTRACT('//case/financiera');

            for myCurEn in ( SELECT  ent."identity"
                         FROM XMLTABLE ('//entity'
                                         PASSING v_entity
                                         COLUMNS "identity" varchar2(2000) PATH '@name' ) ent

            )loop
              v_baseQuestions := v_if02_xml.EXTRACT('//case/financiera/entity[@name='||myCurEn."identity"||']/baseQuestions');
                v_disclosures := v_if02_xml.EXTRACT('//case/financiera/entity[@name='||myCurEn."identity"||']/disclosures');

          end loop;
        END IF;
        RETURN 0;
      EXCEPTION
        WHEN OTHERS THEN
           p_tab_error(f_sysdate, f_user, 'PAC_FINANCIERA.f_extraer_xml_cifin', 2, 'psfinanci=' || psfinanci || ' pnsinterf = ' || pnsinterf, SQLERRM);
           RETURN 1;
      END f_extraer_xml_cifin;

       FUNCTION f_dblink (psperson IN per_personas.sperson%TYPE, pctipper IN per_personas.ctipide%TYPE)
          RETURN NUMBER IS
          v_cantNumPolOsirisLoc NUMBER := 0;
          v_nnumide             per_personas.nnumide%TYPE;
          v_nnumide_aux         per_personas.nnumide%TYPE;
          v_dblink              VARCHAR2(30) := NULL;
          v_sentencia           VARCHAR2(1000):= null;
          v_funcionNumPolOsiris VARCHAR2(30) := 'FN_PUNTAJENUMPOLIZAS';
          v_sentDinamica        VARCHAR2(1000) := NULL;
        BEGIN
             BEGIN
             v_nnumide := pac_isqlfor.f_dni(null,null,psperson);
             v_dblink := f_parinstalacion_t('DBLINK');
             v_sentencia := v_funcionNumPolOsiris||v_dblink;

             IF pctipper = 2 THEN
               v_nnumide_aux := SUBSTR(v_nnumide,1,length(v_nnumide)-1); -- Se quita el digito de verificacin
             ELSE
               v_nnumide_aux := v_nnumide;
             END IF;
             v_sentDinamica := ' begin :v_cantNumPolOsiris := '||v_sentencia||'('|| v_nnumide_aux ||' , '|| pctipper ||' , 1);  end;';
             EXECUTE IMMEDIATE v_sentDinamica
               USING OUT       v_cantNumPolOsirisLoc;
           EXCEPTION
             WHEN OTHERS THEN
               v_cantNumPolOsirisLoc := 0;
           END;
           RETURN v_cantNumPolOsirisLoc;
        END f_dblink;

    /**********************************************************************
      FUNCTION F_FACTOR_S
      Funcin que realiza el clculo del factor S de modelo Zeus, esto como
      parte del clculo del cupo sugerido
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
      FUNCTION f_factor_s(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER IS
        vpasexec            NUMBER(8) := 1;
        vparam              VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
        terror              VARCHAR2(2000);
        vobject             VARCHAR2(200) := 'pac_financiera.f_factor_s';
        num_err             axis_literales.slitera%TYPE := 0;

                    ventasPatrimonio  NUMBER := 0;
                                 cli  NUMBER := 0;
                                 sec  NUMBER := 0;
                             endeuda  NUMBER := 0;
                   margenOperacional  NUMBER := 0;
                   crecimientoVentas  NUMBER := 0;
                     rotacionCartera  NUMBER := 0;
                                  ce  NUMBER := 0;
                       cicloEfectivo  NUMBER := 0;
        resultadoEjericiosAnteriores  NUMBER := 0;
                        utilidadNeta  NUMBER := 0;
                          patrimonio  NUMBER := 0;

                             factorS  NUMBER := 0;

                            V_VENTAS  NUMBER := 0;
                  V_PATRI_ANO_ACTUAL  NUMBER := 0;
                          V_IENDUADA  NUMBER := 0;
                         V_PAS_TOTAL  NUMBER := 0;
                         V_ACT_TOTAL  NUMBER := 0;
                       V_UTIL_OPERAC  NUMBER := 0;
                           V_IMARGEN  NUMBER := 0;
                        V_VT_PER_ANT  NUMBER := 0;
                        V_CARTE_CLIE  NUMBER := 0;
                           V_NDIACAR  NUMBER := 0;
                            V_INVENT  NUMBER := 0;
                          V_COSTO_VT  NUMBER := 0;
                          V_NDIACICL  NUMBER := 0;
                V_PROVEE_CORTO_PLAZO  NUMBER := 0;

                            C_VENTAS  NUMBER := 0;
                  C_PATRI_ANO_ACTUAL  NUMBER := 0;
                          C_IENDUADA  NUMBER := 0;
                         C_PAS_TOTAL  NUMBER := 0;
                         C_ACT_TOTAL  NUMBER := 0;
                       C_UTIL_OPERAC  NUMBER := 0;
                           C_IMARGEN  NUMBER := 0;
                        C_VT_PER_ANT  NUMBER := 0;
                        C_CARTE_CLIE  NUMBER := 0;
                           C_NDIACAR  NUMBER := 0;
                            C_INVENT  NUMBER := 0;
                          C_COSTO_VT  NUMBER := 0;
                          C_NDIACICL  NUMBER := 0;
                C_PROVEE_CORTO_PLAZO  NUMBER := 0;
								-- INI -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS
          								v_max_facS  NUMBER := 0;
								-- INI -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS

         BEGIN
					 -- INI -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable MAX_FACTOR_S (Máximo factor S, modelo de cupos)
					 v_max_facS := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'MAX_FACTOR_S'),0);
					 -- FIN -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable MAX_FACTOR_S (Máximo factor S, modelo de cupos)

            -- 1.  VENTAS/PATRIMONIO


            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_VENTAS
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'VENTAS'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;


            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_PATRI_ANO_ACTUAL
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'PATRI_ANO_ACTUAL'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;


     IF C_VENTAS > 0 AND C_PATRI_ANO_ACTUAL > 0  THEN

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_VENTAS
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'VENTAS'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_PATRI_ANO_ACTUAL
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'PATRI_ANO_ACTUAL'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT (FCS.NVENACT/FCS.NPATRAC)
              INTO V_IENDUADA
              FROM FIN_CIFRAS_SECTORIALES FCS
             WHERE FCS.NCOCIIU IN(SELECT CCIIU
                                FROM FIN_GENERAL FG
                               WHERE FG.SFINANCI = psfinanci)
               AND FCS.FEFECTO =  (SELECT FP.FVALPAR
                                             FROM FIN_PARAMETROS FP
                                            WHERE FP.SFINANCI = psfinanci
                                              AND  FP.NMOVIMI = pnmovimi
                                              AND      CPARAM = 'FECHA_EST_FIN');

            sec := V_IENDUADA;

            IF V_VENTAS < 0 OR V_PATRI_ANO_ACTUAL < 0 THEN
                cli := v_max_facS; -- IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS
            ELSE
                cli := V_VENTAS / V_PATRI_ANO_ACTUAL;
            END IF;


            IF cli <= 0 OR sec = 0 THEN
                ventasPatrimonio := 0;

            END IF;
            -- INI -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS
            IF (cli / sec) > v_max_facS THEN
                ventasPatrimonio := v_max_facS;
            ELSE
                ventasPatrimonio := cli / sec;
            END IF;
						-- FIN -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS

     END IF;

          -- 2. ENDEUDAMIENTO

           SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_PAS_TOTAL
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'PAS_TOTAL'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_ACT_TOTAL
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'ACT_TOTAL'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;


     IF C_PAS_TOTAL > 0 AND C_ACT_TOTAL > 0  THEN

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_PAS_TOTAL
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'PAS_TOTAL'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_ACT_TOTAL
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'ACT_TOTAL'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;


            SELECT (FCS.NTOPAAC/FCS.NTOACAC)
              INTO V_IENDUADA
              FROM FIN_CIFRAS_SECTORIALES FCS
             WHERE FCS.NCOCIIU IN(SELECT CCIIU
                                FROM FIN_GENERAL FG
                               WHERE FG.SFINANCI = psfinanci)
               AND FCS.FEFECTO =  (SELECT FP.FVALPAR
                                             FROM FIN_PARAMETROS FP
                                            WHERE FP.SFINANCI = psfinanci
                                              AND  FP.NMOVIMI = pnmovimi
                                              AND      CPARAM = 'FECHA_EST_FIN');

            IF  V_ACT_TOTAL =  0 THEN
                cli := 0 ;
            ELSE
                cli := V_PAS_TOTAL / V_ACT_TOTAL;
            END IF;

            sec := V_IENDUADA;


            IF cli = 0 THEN
                endeuda := 1;

            END IF;
            -- INI -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS
            IF (sec / cli) > v_max_facS THEN
                endeuda := v_max_facS;
            ELSIF (sec / cli) < v_max_facS Then
                endeuda := sec / cli;
            ELSE
                endeuda := 0;
            END IF;
            -- FIN -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS						

      END IF;

            -- 3. MARGEN OPERACIONAL

            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_UTIL_OPERAC
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'UTIL_OPERAC'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_VENTAS
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'VENTAS'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;


    IF C_UTIL_OPERAC > 0 AND C_VENTAS > 0  THEN

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_UTIL_OPERAC
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'UTIL_OPERAC'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_VENTAS
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'VENTAS'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;


            SELECT (FCS.NUTOPAC/FCS.NVENACT)
              INTO V_IMARGEN
              FROM FIN_CIFRAS_SECTORIALES FCS
             WHERE FCS.NCOCIIU IN(SELECT CCIIU
                                FROM FIN_GENERAL FG
                               WHERE FG.SFINANCI = psfinanci)
               AND FCS.FEFECTO =  (SELECT FP.FVALPAR
                                             FROM FIN_PARAMETROS FP
                                            WHERE FP.SFINANCI = psfinanci
                                              AND  FP.NMOVIMI = pnmovimi
                                              AND      CPARAM = 'FECHA_EST_FIN');

             sec := V_IMARGEN;

            IF V_VENTAS < 0 THEN
                cli := 0;
            ELSE
                cli := V_UTIL_OPERAC / V_VENTAS;
            END IF;
            -- INI -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS
            IF cli <= 0 THEN
                margenOperacional := 0;
            ELSIF sec <= 0 THEN
                margenOperacional := v_max_facS;
            ELSIF (cli / sec) > v_max_facS  THEN
                margenOperacional := v_max_facS;
            ELSE
                margenOperacional := cli / sec;
            END IF;
            -- FIN -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS

    END IF;

            -- 4. CRECIMIENTO VENTAS

            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_VENTAS
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'VENTAS'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_VT_PER_ANT
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'VT_PER_ANT'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;


    IF C_VENTAS > 0 AND C_VT_PER_ANT > 0  THEN

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_VENTAS
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'VENTAS'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_VT_PER_ANT
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'VT_PER_ANT'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;


             SELECT (FCS.NVENACT - FCS.NVENANT)/(FCS.NVENANT)
              INTO V_IENDUADA
              FROM FIN_CIFRAS_SECTORIALES FCS
             WHERE FCS.NCOCIIU IN(SELECT CCIIU
                                FROM FIN_GENERAL FG
                               WHERE FG.SFINANCI = psfinanci)
               AND FCS.FEFECTO =  (SELECT FP.FVALPAR
                                             FROM FIN_PARAMETROS FP
                                            WHERE FP.SFINANCI = psfinanci
                                              AND  FP.NMOVIMI = pnmovimi
                                              AND      CPARAM = 'FECHA_EST_FIN');


             sec := V_IENDUADA;

            IF V_VT_PER_ANT <= 0 THEN
                cli := 0;
            ELSE
                cli := (V_VENTAS - V_VT_PER_ANT) / V_VT_PER_ANT;
            END IF;

            IF cli <= 0 THEN
                    crecimientoVentas := 0;
            END IF;
            -- INI -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS
            IF sec <= 0 THEN
                    crecimientoVentas := v_max_facS;
            ELSE
              IF (cli / sec) > v_max_facS THEN
                crecimientoVentas := v_max_facS;
              ELSE
                crecimientoVentas := cli / sec;
              END IF;
            END IF;
            -- FIN -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS


     END IF;

            -- 5. ROTACION CARTERA

            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_CARTE_CLIE
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'CARTE_CLIE'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_VENTAS
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'VENTAS'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;


       IF C_CARTE_CLIE > 0 AND C_VENTAS > 0  THEN

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_CARTE_CLIE
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'CARTE_CLIE'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_VENTAS
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'VENTAS'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;


            SELECT (FCS.NCUCOAC * 360)/(FCS.NVENACT)
              INTO V_NDIACAR
              FROM FIN_CIFRAS_SECTORIALES FCS
             WHERE FCS.NCOCIIU IN(SELECT CCIIU
                                FROM FIN_GENERAL FG
                               WHERE FG.SFINANCI = psfinanci)
               AND FCS.FEFECTO =  (SELECT FP.FVALPAR
                                             FROM FIN_PARAMETROS FP
                                            WHERE FP.SFINANCI = psfinanci
                                              AND  FP.NMOVIMI = pnmovimi
                                              AND      CPARAM = 'FECHA_EST_FIN');

               sec := V_NDIACAR;

              IF V_VENTAS < 0 THEN
                cli := 0;
              ELSE
                cli := (V_CARTE_CLIE * 360) / V_VENTAS;
              END IF;
              -- INI -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS
              IF cli < 0 THEN
                      rotacionCartera := 0;
              ELSIF (cli = 0 AND sec = 0) OR (cli > 0 AND sec = 0) THEN
                      rotacionCartera := 1;
              ELSIF cli = 0 AND sec > 0 THEN
                      rotacionCartera := v_max_facS;
              ELSIF (sec / cli) > v_max_facS THEN
                      rotacionCartera := v_max_facS;
              ELSE
                      rotacionCartera := sec / cli;
              END IF;
							-- FIN -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS

    END IF;




            -- 6. CICLO EFECTIVO
            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_INVENT
              FROM FIN_PARAMETROS
             WHERE  CPARAM = 'INVENT'
              AND SFINANCI = psfinanci
              AND  NMOVIMI = pnmovimi;

            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_VENTAS
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'VENTAS'
              AND SFINANCI = psfinanci
              AND  NMOVIMI = pnmovimi;

            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_CARTE_CLIE
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'CARTE_CLIE'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_COSTO_VT
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'COSTO_VT'
             AND SFINANCI = psfinanci
             AND  NMOVIMI = pnmovimi;


             SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO C_PROVEE_CORTO_PLAZO
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'PROVEE_CORTO_PLAZO'
             AND SFINANCI = psfinanci
             AND  NMOVIMI = pnmovimi;



      IF C_INVENT > 0 AND C_VENTAS > 0 AND C_CARTE_CLIE > 0 AND C_COSTO_VT > 0 AND C_PROVEE_CORTO_PLAZO > 0  THEN

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_INVENT
              FROM FIN_PARAMETROS
             WHERE  CPARAM = 'INVENT'
              AND SFINANCI = psfinanci
              AND  NMOVIMI = pnmovimi;

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_VENTAS
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'VENTAS'
              AND SFINANCI = psfinanci
              AND  NMOVIMI = pnmovimi;

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_CARTE_CLIE
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'CARTE_CLIE'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_COSTO_VT
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'COSTO_VT'
             AND SFINANCI = psfinanci
             AND  NMOVIMI = pnmovimi;

             SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO V_PROVEE_CORTO_PLAZO
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'PROVEE_CORTO_PLAZO'
             AND SFINANCI = psfinanci
             AND  NMOVIMI = pnmovimi;


            SELECT ((FCS.NCUCOAC * 360) / FCS.NVENACT) + (360 / (FCS.NCOVEAC / NINVEAC)) -  ((FCS.NPROVAC * 360) / NCOVEAC)
              INTO V_NDIACICL
              FROM FIN_CIFRAS_SECTORIALES FCS
             WHERE FCS.NCOCIIU IN(SELECT CCIIU
                                FROM FIN_GENERAL FG
                               WHERE FG.SFINANCI = psfinanci)
               AND FCS.FEFECTO =  (SELECT FP.FVALPAR
                                             FROM FIN_PARAMETROS FP
                                            WHERE FP.SFINANCI = psfinanci
                                              AND  FP.NMOVIMI = pnmovimi
                                              AND      CPARAM = 'FECHA_EST_FIN');
               sec := V_NDIACICL;

              IF V_VENTAS <> 0 AND V_COSTO_VT <> 0 AND V_INVENT <> 0 THEN
               cli := ((V_CARTE_CLIE * 360) / V_VENTAS)  + (360 / (V_COSTO_VT / V_INVENT )) - ((V_PROVEE_CORTO_PLAZO * 360) / V_COSTO_VT);
              ELSE
               cli := 0;
              END IF;

              -- INI -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS
              IF cli <= 0 AND sec <= 0 THEN
                      cicloEfectivo := 1;
              ELSIF  cli <= 0 AND sec > 0 THEN
                      cicloEfectivo := v_max_facS;
              ELSIF  cli < 0 AND sec < 0 THEN
                      cicloEfectivo := cli / sec;
              ELSIF  cli > 0 AND sec <= 0 THEN
                      cicloEfectivo := 0;
              ELSIF (sec / cli) > v_max_facS THEN
                      cicloEfectivo := v_max_facS;
              ELSE
                      cicloEfectivo := sec / cli;
              END IF;
							-- FIN -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable v_max_facS

      END IF;

               -- 7.  CALCULO FINAL
                              utilidadNeta := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'UTIL_NETA');
              resultadoEjericiosAnteriores := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'RES_EJER_ANT');
                                patrimonio := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'PATRI_ANO_ACTUAL');

              IF (utilidadNeta + resultadoEjericiosAnteriores) <= (2 * patrimonio * -1) Then
                  factorS := 0;
              ELSE
                  factorS := (ventasPatrimonio * 0.2) + (endeuda * 0.2) + (margenOperacional * 0.25) + (crecimientoVentas * 0.15) + (rotacionCartera * 0.12) + (cicloEfectivo * 0.08);
              END IF;




            RETURN factorS;

         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM||' - '||dbms_utility.format_error_backtrace);
               RETURN num_err;
       END f_factor_s;


    /**********************************************************************
      FUNCTION f_factor_r
      Funcin que realiza el clculo del factor Riesgo del Pais para
      extranjeros del modelo Zeus, esto como parte del clculo del cupo
      sugerido
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
		 -- INI - IAXIS-4242 - JLTS - 23/05/2019. Se ajusta la tabla de la funcion
      FUNCTION f_factor_r(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER IS
        vpasexec            NUMBER(8) := 1;
        vparam              VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
        terror              VARCHAR2(2000);
        vobject             VARCHAR2(200) := 'pac_financiera.f_factor_r';
        num_err             axis_literales.slitera%TYPE := 0;

         V_SPERSON  NUMBER := 0;
           V_CPAIS  NUMBER := 0;
         V_NCALIFT  NUMBER := 0;
         C_NCALIFT  NUMBER := 0;

       BEGIN

            SELECT SPERSON
              INTO V_SPERSON
              FROM FIN_GENERAL
             WHERE SFINANCI = PSFINANCI;

            SELECT CPAIS
              INTO V_CPAIS
              FROM PER_DETPER
             WHERE SPERSON = V_SPERSON;


            SELECT COUNT(F.NCALIFT)
              INTO C_NCALIFT
              FROM FIN_PAIS_RIESGO F
             WHERE CPAIS = V_CPAIS
						   AND F.NMOVIMI = (select max (f1.nmovimi) 
							                    from FIN_PAIS_RIESGO F1
																where F1.CPAIS = f.cpais)
               AND f.nanio_efecto = (SELECT TO_CHAR(FP.FVALPAR,'YYYY')
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN')
               AND ROWNUM = 1;

           IF C_NCALIFT > 0 THEN
              SELECT F.NCALIFT
                INTO V_NCALIFT
              FROM FIN_PAIS_RIESGO F
             WHERE CPAIS = V_CPAIS
               AND F.NMOVIMI = (select max (f1.nmovimi) 
                                  from FIN_PAIS_RIESGO F1
                                where F1.CPAIS = f.cpais)
               AND f.nanio_efecto = (SELECT TO_CHAR(FP.FVALPAR,'YYYY')
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN')
               AND ROWNUM = 1;
           END IF;

        RETURN V_NCALIFT;

        EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_factor_r;
			 -- FIN - IAXIS-4242 - JLTS - 23/05/2019. Se ajusta la tabla de la funcion


    /**********************************************************************
      FUNCTION f_factor_f
      Funcin que realiza el clculo del factor Financiero para extranjeros,
      esto como parte del clculo del cupo sugerido
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_factor_f(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER IS
        vpasexec            NUMBER(8) := 1;
        vparam              VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
        terror              VARCHAR2(2000);
        vobject             VARCHAR2(200) := 'pac_financiera.f_factor_f';
        num_err             axis_literales.slitera%TYPE := 0;

                      v_ventas  NUMBER := 0;
                 v_activoTotal  NUMBER := 0;
                  ventasActivo  NUMBER := 0;
                 fVentasActivo  NUMBER := 0;
                      v_pasivo  NUMBER := 0;
                    v_p_activo  NUMBER := 0;
                  pasivoActivo  NUMBER := 0;
                      v_activo  NUMBER := 0;
                 fPasivoActivo  NUMBER := 0;
              v_obligacionesCP  NUMBER := 0;
          obligacionesCPVentas  NUMBER := 0;
         fObligacionesCPVentas  NUMBER := 0;
                   v_gastosFin  NUMBER := 0;
               v_utOperacional  NUMBER := 0;
        gastosFinUtOperacional  NUMBER := 0;
       fGastosFinUtOperacional  NUMBER := 0;
                   v_ventasAnt  NUMBER := 0;
             crecimientoVentas  NUMBER := 0;
            fCrecimientoVentas  NUMBER := 0;
           utOperacionalVentas  NUMBER := 0;
          fUtOperacionalVentas  NUMBER := 0;
                      v_utNeta  NUMBER := 0;
                  v_patrimonio  NUMBER := 0;
              utNetaPatrimonio  NUMBER := 0;
                  fUtNetaPatri  NUMBER := 0;
                     v_acTotal  NUMBER := 0;
                 utNetaAcTotal  NUMBER := 0;
                fUtNetaAcTotal  NUMBER := 0;
               v_patrimonioAnt  NUMBER := 0;
                     crecpatri  NUMBER := 0;
                    fcrecpatri  NUMBER := 0;
                       factorF  NUMBER := 0;

              c_obligacionesCP  NUMBER := 0;

       BEGIN

        -- 1. VENTAS/ACTIVO
               v_ventas := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'VENTAS');
          v_activoTotal := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'ACT_TOTAL');

        IF (v_ventas <= 0) OR (v_activoTotal <= 0) THEN
                ventasActivo := 0;
        ELSE
                ventasActivo := v_ventas / v_activoTotal;
        END IF;

             fVentasActivo := F_GET_FIN_RANGO('VENTAS_ACTIVO', ventasActivo);


        -- 2. PASIVO ACTIVO
              v_pasivo := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'PAS_TOTAL');
            v_p_activo := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'ACT_TOTAL');

        IF (v_pasivo <= 0) OR (v_p_activo <= 0) THEN
                pasivoActivo := 0;
        ELSE
                pasivoActivo := v_pasivo / v_p_activo;
        END IF;

            fPasivoActivo := F_GET_FIN_RANGO('PASIVO_ACTIVO', pasivoActivo);

         -- 3.  ObligacionesCPVentas

              v_ventas := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'VENTAS');

            SELECT COUNT(IOBLCP)
              INTO c_obligacionesCP
              FROM FIN_INDICADORES
             WHERE SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO c_obligacionesCP
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'O_FIN_CORTO_PLAZO'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

         IF c_obligacionesCP > 0 THEN
            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO v_obligacionesCP
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'O_FIN_CORTO_PLAZO'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;
         END IF;

        IF (v_obligacionesCP <= 0) OR (v_ventas <= 0) THEN
            obligacionesCPVentas := 2;
        ELSE
            obligacionesCPVentas := v_obligacionesCP / v_ventas;
        END IF;

           fObligacionesCPVentas := F_GET_FIN_RANGO('OBLIGACIONES_CP_VENTAS', obligacionesCPVentas);


         -- 4.   GastosFinUtOperacional
                   v_gastosFin := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'GASTO_FIN');
               v_utOperacional := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'UTIL_OPERAC');

          IF (v_gastosFin <= 0) OR (v_utOperacional <= 0) THEN
                  gastosFinUtOperacional := 0;
          ELSE
                  gastosFinUtOperacional := v_gastosFin / v_utOperacional;
          END IF;

             fGastosFinUtOperacional := F_GET_FIN_RANGO('GASTOS_FIN_UT_OPERACIONAL', gastosFinUtOperacional);

         -- 5.  CrecimientoVentas
               v_ventas := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'VENTAS');
            v_ventasAnt := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'VT_PER_ANT');

          IF (v_ventas <= 0) OR (v_ventasAnt <= 0) THEN
                crecimientoVentas := 0;
          ELSE
                crecimientoVentas := (v_ventas - v_ventasAnt) / v_ventasAnt;
          END IF;

            fCrecimientoVentas := F_GET_FIN_RANGO('CRECIMIENTO_VENTAS', crecimientoVentas);


         -- 6.  UtOperacionalVentas
             v_utOperacional := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'VENTAS');
                    v_ventas := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'UTIL_OPERAC');

          IF (v_utOperacional <= 0) OR (v_ventas <= 0) THEN
                  utOperacionalVentas := 0;
              -- Exit Function;
          ELSE
                  utOperacionalVentas := v_utOperacional / v_ventas;
          END IF;

             fUtOperacionalVentas := F_GET_FIN_RANGO('UT_OPER_VENTAS', utOperacionalVentas);


         -- 7.  UtNetaPatrimonio

                v_utNeta := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'UTIL_NETA');
            v_acTotal := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'ACT_TOTAL');

          IF (v_utNeta <= 0) OR (v_acTotal <= 0) THEN
                 utNetaPatrimonio := 0;
          ELSE
                 utNetaPatrimonio := v_utNeta / v_acTotal;
          END IF;


              fUtNetaPatri := F_GET_FIN_RANGO('UT_NETA_PATRIM', utNetaPatrimonio);


         -- 8.   UtNetaActivoTotal

             v_utNeta := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'UTIL_NETA');
            v_patrimonio := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'PATRI_ANO_ACTUAL');

         IF (v_utNeta <= 0) OR (v_patrimonio <= 0) THEN
                utNetaAcTotal := 0;
         ELSE
                utNetaAcTotal := v_utNeta /v_patrimonio ;
         END IF;

            fUtNetaAcTotal := F_GET_FIN_RANGO('UT_NETA_ACT_TOTAL', UtNetaAcTotal);


         -- 9.  CrecimientoPatrimonio
               v_patrimonio :=  PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'PATRI_ANO_ACTUAL');
            v_patrimonioAnt :=  PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'PATRI_PERI_ANT');

         IF (v_patrimonio <= 0) OR (v_patrimonioAnt <= 0) THEN
                crecpatri := 0;
         ELSE
                crecpatri := (v_patrimonio - v_patrimonioAnt) / v_patrimonioAnt;
         END IF;

            fcrecpatri := F_GET_FIN_RANGO('CRECIMIENTO_PATRIMONIO', crecpatri);

          -- 10.  CALCULO FINAL  FACTOR FINANCIERO

         factorF := (fVentasActivo * 0.15)
                  + (fPasivoActivo * 0.15)
                  + (fObligacionesCPVentas * 0.1)
                  + (fGastosFinUtOperacional * 0.1)
                  + (fCrecimientoVentas * 0.1)
                  + (fUtOperacionalVentas *0.15)
                  + (fUtNetaAcTotal * 0.1)
                  + (fUtNetaPatri * 0.05) + (fcrecpatri * 0.1);

        RETURN factorF;

        EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_factor_f;

     /**********************************************************************
      FUNCTION f_factor_z
      Funcin que realiza el clculo del factor Z Altman, esto como parte
      del clculo del cupo sugerido
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
      FUNCTION f_factor_z(psfinanci IN NUMBER, pnmovimi IN NUMBER)
        RETURN NUMBER IS
        vpasexec NUMBER(8) := 1;
        vparam   VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
        terror   VARCHAR2(2000);
        vobject  VARCHAR2(200) := 'pac_financiera.f_factor_z';
        num_err  axis_literales.slitera%TYPE := 0;

        v_at                     NUMBER := 0;
        v_x1                     NUMBER := 0;
        v_factorZ                NUMBER := 0;
        v_activoCorriente        NUMBER := 0;
        v_pasivoCorriente        NUMBER := 0;
        v_activoTotal            NUMBER := 0;
        v_utilidadesRetenidas    NUMBER := 0;
        v_x2                     NUMBER := 0;
        v_utilidadesAnteImpuesto NUMBER := 0;
        v_gastosFinancieros      NUMBER := 0;
        v_x3                     NUMBER := 0;
        v_pasivoTotal            NUMBER := 0;
        v_patrimonio             NUMBER := 0;
        v_x4                     NUMBER := 0;
        v_z                      NUMBER := 0;

      BEGIN

        -- 1.   VARIABLE X1
        v_activoCorriente := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI,
                                                            PNMOVIMI,
                                                            'ACT_CORR');
        v_pasivoCorriente := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI,
                                                            PNMOVIMI,
                                                            'PAS_CORR');
        v_activoTotal     := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI,
                                                            PNMOVIMI,
                                                            'ACT_TOTAL');

        --    IF  v_at = 0 THEN
        --        v_x1 := 0;
        --    ELSE
        v_x1 := (v_activoCorriente - v_pasivoCorriente) / v_activoTotal;
        --    END IF;

        -- 2.  VARIABLE X2
        v_utilidadesRetenidas := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI,
                                                                PNMOVIMI,
                                                                'RES_EJER_ANT');
        v_activoTotal         := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI,
                                                                PNMOVIMI,
                                                                'ACT_TOTAL');

        IF v_activoTotal = 0 THEN
          v_x2 := 0;
        ELSE
          v_x2 := v_utilidadesRetenidas / v_activoTotal;
        END IF;

        -- 3.  VARIABLE X3
        v_utilidadesAnteImpuesto := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI,
                                                                   PNMOVIMI,
                                                                   'RES_ANT_IMP');
        v_activoTotal            := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI,
                                                                   PNMOVIMI,
                                                                   'ACT_TOTAL');
        v_gastosFinancieros      := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI,
                                                                   PNMOVIMI,
                                                                   'GASTO_FIN');

        IF v_activoTotal = 0 THEN
          v_x3 := 0;
        ELSE
          v_x3 := (v_utilidadesAnteImpuesto + v_gastosFinancieros) /
                  v_activoTotal;
        END IF;

        -- 4.  VARIABLE X4

        v_pasivoTotal := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI,
                                                        PNMOVIMI,
                                                        'PAS_TOTAL');
        v_patrimonio  := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI,
                                                        PNMOVIMI,
                                                        'PATRI_ANO_ACTUAL');

        IF v_pasivoTotal = 0 THEN
          v_x4 := 0;
        ELSE
          v_x4 := v_patrimonio / v_pasivoTotal;
        END IF;

        -- 5.  CALCULO FINAL  FACTOR Z ALTMAN
        v_z := (6.56 * v_x1) + (3.26 * v_x2) + (6.72 * v_x3) +
               (1.05 * v_x4);

        v_factorZ := F_GET_FIN_RANGO('VARIABLE_Z_ALTMAN',
                                     v_z);

        RETURN v_factorZ;

      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          num_err := 9907950; --falta add literal
          p_tab_error(f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLERRM);
          RETURN num_err;
      END f_factor_z;


    /**********************************************************************
      FUNCTION f_factor_c
      Funcin que realiza el clculo del factor de Caja Personas Juridicas,
      esto como parte del clculo del cupo sugerido:
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_factor_c(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER IS
        vpasexec            NUMBER(8) := 1;
        vparam              VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
        terror              VARCHAR2(2000);
        vobject             VARCHAR2(200) := 'pac_financiera.f_factor_c';
        num_err             axis_literales.slitera%TYPE := 0;

                  v_factorC  NUMBER := 0;
          v_activoCorriente  NUMBER := 0;
          v_pasivoCorriente  NUMBER := 0;
           v_razonCorriente  NUMBER := 0;
                       v_X1  NUMBER := 0;
              v_inventarios  NUMBER := 0;
                   v_ventas  NUMBER := 0;
           v_carteraCliente  NUMBER := 0;
              v_costoVentas  NUMBER := 0;
            v_cicloEfectivo  NUMBER := 0;
                       v_X2  NUMBER := 0;
              v_proveedores  NUMBER := 0;

                 c_costo_vt  NUMBER := 0;
                   c_invent  NUMBER := 0;
              c_proveedores  NUMBER := 0;

       BEGIN


            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO c_costo_vt
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'COSTO_VT'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO c_invent
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'INVENT'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO c_proveedores
              FROM FIN_PARAMETROS
             WHERE CPARAM = 'PROVEE_CORTO_PLAZO'
               AND SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi;

        --  1.  X1 Razon corriente
             v_activoCorriente := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'ACT_CORR');
             v_pasivoCorriente := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'PAS_CORR');

          IF v_activoCorriente <= 0 OR v_pasivoCorriente <= 0 THEN
                  v_razonCorriente := 0;
          ELSE
                  v_razonCorriente := v_activoCorriente / v_pasivoCorriente;
          END IF;
          ---- Calificacion Razon Corriente  (X1)

              v_X1 := F_GET_FIN_RANGO('RAZON_CORRIENTE', v_razonCorriente);


        -- 2. X2 CICLO EFECTIVO
                 v_inventarios := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'INVENT');
                      v_ventas := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'VENTAS');
              v_carteraCliente := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'CARTE_CLIE');
                 v_costoVentas := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'COSTO_VT');
                 v_proveedores := PAC_FINANCIERA.F_GET_FIN_PARAM(PSFINANCI, PNMOVIMI, 'PROVEE_CORTO_PLAZO');

             IF (v_ventas <> 0) THEN
               v_cicloEfectivo := ((v_carteraCliente * 360) / v_ventas);
             END IF;

            IF c_costo_vt > 0  AND c_invent > 0 AND c_proveedores > 0 THEN
        -- INI -TCS_456 -JLTS - 11/01/2019 - Ajuste de las condicionales de este factor
              IF v_inventarios <> 0 AND v_costoVentas <> 0 AND v_proveedores <> 0 THEN
                 v_cicloEfectivo := v_cicloEfectivo + (360 / (v_costoVentas / v_inventarios )) - ((v_proveedores * 360) / v_costoVentas);

                  -- Calificacion Ciclo efectivo

                         v_X2 := F_GET_FIN_RANGO('CICLO_EFECTIVO', v_cicloEfectivo);
                         -- revisar
                         -- v_X2 := 0.9;

                  -- 3. Calculo Final Factor C

                    v_factorC := (v_X1 * 0.4) + (v_X2 * 0.6);

               ELSE
                 v_factorC := 1;
               END IF;
            ELSIF c_costo_vt > 0 AND c_proveedores > 0 THEN
               IF v_costoVentas <> 0 AND v_proveedores <> 0 THEN
                 v_cicloEfectivo := v_cicloEfectivo - ((v_proveedores * 360) / v_costoVentas);

                  -- Calificacion Ciclo efectivo

                         v_X2 := F_GET_FIN_RANGO('CICLO_EFECTIVO', v_cicloEfectivo);
                         -- revisar
                         -- v_X2 := 0.9;

                  -- 3. Calculo Final Factor C

                    v_factorC := (v_X1 * 0.4) + (v_X2 * 0.6);
        -- FIN -TCS_456 -JLTS - 11/01/2019 - Ajuste de las condicionales de este factor
            ELSE
              v_factorC := 1;
            END IF;
         ELSE
              v_factorC := 1;
         END IF;

        RETURN v_factorC;

        EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_factor_c;


     /**********************************************************************
      FUNCTION f_factor_n
      Funcin que realiza el clculo para personas naturales, esto como parte
      del clculo del cupo sugerido:
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_factor_n(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER IS
        vpasexec            NUMBER(8) := 1;
        vparam              VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
        terror              VARCHAR2(2000);
        vobject             VARCHAR2(200) := 'pac_financiera.f_factor_n';
        num_err             axis_literales.slitera%TYPE := 0;

            v_factorN  NUMBER := 0;
             v_nscore  NUMBER := 0;
           v_nfacifin  NUMBER := 0;
     -- INI CP0390M_SYS_PERS - JLTS - 20181206 -- Se ajusta la condicin
           v_iminimo_m NUMBER := 0; -- Mensual
           v_iminimo_a NUMBER := 0; -- Anual
     -- FIN CP0390M_SYS_PERS - JLTS - 20181206 -- Se ajusta la condicin
               v_cupo  NUMBER := 0;
             -- INI -IAXIS-4143 -JLTS - 24/05/2019 Se crea la variable v_ing_min
             v_ing_min number := 0;
             --  FIN -IAXIS-4143 -JLTS - 24/05/2019 

       BEGIN

            SELECT NSCORE
              INTO v_nscore
              FROM FIN_ENDEUDAMIENTO
             WHERE SFINANCI = psfinanci;

             v_nfacifin := F_GET_FIN_RANGO('CALIFICACION_CIFIN', v_nscore);
             -- INI -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable INGR_MIN_PROMANU_CLI (Ingreso mínimo promedio anual cliente)
             v_ing_min := NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'INGR_MIN_PROMANU_CLI'),0);
             --  FIN -IAXIS-4143 -JLTS - 24/05/2019 
             --  CALCULO FINAL CUPO DE LA PERSONA
            -- INI CP0390M_SYS_PERS - JLTS - 20181206 -- Se ajusta la condicin
            SELECT IMINIMO
              INTO v_iminimo_m
              FROM FIN_ENDEUDAMIENTO
             WHERE SFINANCI = psfinanci;
             v_iminimo_a := (v_iminimo_m*12);
              --  Revisar
               v_cupo := v_iminimo_a * (v_nfacifin + F_FACTOR_P(psfinanci, pnmovimi) + F_FACTOR_A(psfinanci, pnmovimi));
             -- INI -IAXIS-4143 -JLTS - 24/05/2019 Se ajusta la formula para que tome la variable v_ing_min
             IF v_cupo > v_iminimo_a  * v_ing_min THEN
                v_cupo := v_iminimo_a  * v_ing_min;
             END IF;
             -- FIN -IAXIS-4143 -JLTS - 24/05/2019.
             -- FIN CP0390M_SYS_PERS - JLTS - 20181206 -- Se ajusta la condicin
          -- Revisar retorno.
         RETURN v_cupo;

        EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_factor_n;


     /**********************************************************************
      FUNCTION f_factor_p
      Funcin que realiza el clculo de plizas asociadas a la persona y su
      calificacin correspondiente, esto como parte del clculo del cupo
      sugerido
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_factor_p(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER IS
        vpasexec            NUMBER(8) := 1;
        vparam              VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
        terror              VARCHAR2(2000);
        vobject             VARCHAR2(200) := 'pac_financiera.f_factor_p';
        num_err             axis_literales.slitera%TYPE := 0;

                     v_factorP  NUMBER := 0;
                     v_sperson  NUMBER := 0;
                     v_cagente  NUMBER := 0;
          v_cantPolizasCliente  NUMBER := 0;
         v_cantPolizasClienteP  NUMBER := 0;
         v_cantPolizasClienteT  NUMBER := 0;
                     v_nfactp   NUMBER := 0;
                     v_ctipper  NUMBER := 0;



        -- INI - TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS
        v_cantNumPolOsiris           NUMBER := 0;
        v_nnumide                    PER_PERSONAS.NNUMIDE%TYPE := NULL;
        v_nnumide_aux                PER_PERSONAS.NNUMIDE%TYPE := NULL;

        -- FIN - TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS
        BEGIN

            -- Revisar

            SELECT SPERSON
              INTO v_sperson
              FROM FIN_GENERAL
             WHERE SFINANCI = psfinanci;

           SELECT CTIPPER
              INTO v_ctipper
              FROM PER_PERSONAS
             WHERE SPERSON = (SELECT SPERSON
                                FROM FIN_GENERAL
                               WHERE SFINANCI = PSFINANCI);

           -- INI TCS_9998 IAXIS-2490 - 24/02/2019  - JLTS - Convivencia apuntando a la BBDD de OSIRIS
           -- AQUI
           v_cantNumPolOsiris := f_dblink(v_sperson,v_ctipper);
           --
           -- FIN TCS_9998 IAXIS-2490 - 24/02/2019  - JLTS

           -- INI CP0390M_SYS_PERS - JLTS - 20181206 -- Se ajusta la condicin
           SELECT COUNT(NPOLIZA) -- revisado
             INTO v_cantPolizasCliente
             FROM SEGUROS s
            WHERE exists (select 1
                            from tomadores t
                           where t.sseguro = s.sseguro
                             and t.sperson = v_sperson)
              AND s.cpolcia is null;  -- TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS - Se excluyen las plizas migradas


             IF v_cantPolizasCliente = 0 THEN

                SELECT COUNT(NVALPAR)
                  INTO v_cantPolizasCliente
                  FROM PER_PARPERSONAS
                 WHERE  CPARAM = 'NUM_POLIZAS'
                   AND SPERSON = v_sperson;

                IF v_cantPolizasCliente > 0 THEN
                      SELECT NVALPAR
                        INTO v_cantPolizasClienteP
                        FROM PER_PARPERSONAS
                       WHERE  CPARAM = 'NUM_POLIZAS'
                         AND SPERSON = v_sperson;
               END IF;
             END IF;
             -- FIN CP0390M_SYS_PERS - JLTS - 20181206 -- Se ajusta la condicin
             -- INI - TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS - Se adicionan las plizas de Osiris (v_cantNumPolOsiris) y se actualiza
             --                                                  la tabla IN_INDICADORES con el dato correspondiente
             v_cantPolizasClienteT := v_cantPolizasClienteP + v_cantPolizasCliente + v_cantNumPolOsiris;
             UPDATE FIN_INDICADORES f
               SET f.ncontpol = v_cantPolizasClienteT
             WHERE f.sfinanci = psfinanci
               AND f.nmovimi = pnmovimi;
             -- FIN - TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS - Se adicionan las plizas de Osiris
             v_nfactp := F_GET_FIN_RANGO('CALIFICACION_POLIZAS', v_cantPolizasClienteT);

              IF v_ctipper = 1 THEN
                v_nfactp := F_GET_FIN_RANGO('CALIFICACION_POLIZAS_N', v_cantPolizasClienteT);
              ELSIF v_ctipper = 2 THEN
                v_nfactp := F_GET_FIN_RANGO('CALIFICACION_POLIZAS', v_cantPolizasClienteT);
              END IF;
         RETURN v_nfactp;

        EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_factor_p;


    /**********************************************************************
      FUNCTION f_factor_a
      Funcin que realiza el clculo de anios e experiencia de la persona dentro
      de la compaa aseguradora y su calificacin correspondiente, esto como
      parte del clculo del cupo sugerido:
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_factor_a(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER)
       RETURN NUMBER IS
        vpasexec            NUMBER(8) := 1;
        vparam              VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
        terror              VARCHAR2(2000);
        vobject             VARCHAR2(200) := 'pac_financiera.f_factor_a';
        num_err             axis_literales.slitera%TYPE := 0;

                              v_contaC  NUMBER := 0;
                             v_factorA  NUMBER := 0;
                             v_sperson  NUMBER := 0;
                              v_nfactp  NUMBER := 0;
         v_cantAniosVinculacionCliente  NUMBER := 0;
        v_cantAniosVinculacionClienteP  NUMBER := 0;
                             v_cagente  NUMBER := 0;
                              p_fecfin  Date;
                              p_fecini  Date;
                           p_fecpripol  Date;
                             v_ctipper  NUMBER := 0;
        -- INI - TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS
          v_dblink                     VARCHAR2(30) := NULL;
          v_cantAniosVincOsiris        NUMBER := 0;
          v_cantAniosVincAll           NUMBER := 0;
          v_funcionAniosVincOsiris     VARCHAR2(30) := 'FN_PUNTAJEAOSVIGENTE';
          v_sentencia                  VARCHAR2(1000):= null;
          v_sentDinamica               VARCHAR2(1000) := NULL;
          v_nnumide                    PER_PERSONAS.NNUMIDE%TYPE := NULL;
          v_nnumide_aux                PER_PERSONAS.NNUMIDE%TYPE := NULL;
        -- FIN - TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS


         BEGIN

             SELECT SPERSON
              INTO v_sperson
              FROM FIN_GENERAL
             WHERE SFINANCI = psfinanci;

           -- INI CP0390M_SYS_PERS - JLTS - 20181206 -- Se ajusta la condicin
           SELECT MIN(FEFECTO), MAX(FEFECTO) -- revisado
             INTO p_fecini, p_fecfin
             FROM SEGUROS s
            WHERE exists (select 1
                            from tomadores t
                           where t.sseguro = s.sseguro
                             and t.sperson = v_sperson)
              AND s.cpolcia is null;  -- TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS - Se excluyen las plizas migradas
           -- FIN CP0390M_SYS_PERS - JLTS - 20181206 -- Se ajusta la condicin

            SELECT CTIPPER
              INTO v_ctipper
              FROM PER_PERSONAS
             WHERE SPERSON = (SELECT SPERSON
                                FROM FIN_GENERAL
                               WHERE SFINANCI = PSFINANCI);

           -- INI TCS_9998 IAXIS-2490 - 24/02/2019  - JLTS - Convivencia apuntando a la BBDD de OSIRIS
           BEGIN
             v_nnumide := pac_isqlfor.f_dni(null,null,v_sperson);
             v_dblink := f_parinstalacion_t('DBLINK');
             v_sentencia := v_funcionAniosVincOsiris||v_dblink;
             IF v_ctipper = 2 THEN
               v_nnumide_aux := SUBSTR(v_nnumide,1,length(v_nnumide)-1);
             ELSE
               v_nnumide_aux := v_nnumide;
             END IF;
             v_sentDinamica := ' begin :v_cantAniosVincOsiris := '||v_sentencia||'('|| v_nnumide_aux ||' , '|| v_ctipper ||' , 1);  end;';
             EXECUTE IMMEDIATE v_sentDinamica
               USING OUT       v_cantAniosVincOsiris;
           EXCEPTION
             WHEN OTHERS THEN
               v_cantAniosVincOsiris := 0;
           END;
           --
           -- FIN TCS_9998 IAXIS-2490 - 24/02/2019  - JLTS

           IF p_fecini IS NOT NULL THEN
              v_cantAniosVinculacionCliente := FLOOR ( MONTHS_BETWEEN ( TRUNC( p_fecfin ), TRUNC( p_fecini ) ) / 12 );
           END IF;

           -- INI CP0390M_SYS_PERS - JLTS - 20181206 -- Se ajusta la condicin
            SELECT COUNT(FVALPAR)
               INTO v_cantAniosVinculacionClienteP
              FROM PER_PARPERSONAS
             WHERE  CPARAM = 'FECHA_PRI_POL'
               AND SPERSON = v_sperson;
           -- INI CP0390M_SYS_PERS - JLTS - 20181206 -- Se ajusta la condicin


              IF v_cantAniosVinculacionClienteP > 0 THEN

               -- INI CP0390M_SYS_PERS - JLTS - 20181206 -- Se ajusta la condicin
                SELECT FVALPAR
                 INTO p_fecpripol
                FROM PER_PARPERSONAS
               WHERE  CPARAM = 'FECHA_PRI_POL'
                 AND SPERSON = v_sperson;
               -- FIN CP0390M_SYS_PERS - JLTS - 20181206 -- Se ajusta la condicin

                IF p_fecpripol IS NOT NULL THEN
                   v_cantAniosVinculacionClienteP := FLOOR ( MONTHS_BETWEEN ( TRUNC( SYSDATE ), TRUNC( p_fecpripol ) ) / 12 );
                END IF;

              END IF;
            -- INI - TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS
            v_cantAniosVincAll := greatest(v_cantAniosVinculacionCliente,v_cantAniosVinculacionClienteP, v_cantAniosVincOsiris);
            UPDATE FIN_INDICADORES f
               SET f.naniosvinc = v_cantAniosVincAll
             WHERE f.sfinanci = psfinanci
               AND f.nmovimi = pnmovimi;
            /*IF v_cantAniosVinculacionCliente >=v_cantAniosVinculacionClienteP THEN*/
            IF v_ctipper = 1 THEN
              v_nfactp := F_GET_FIN_RANGO('CALIFICACION_EXP_N', v_cantAniosVincAll);
            ELSIF v_ctipper = 2 THEN
              v_nfactp := F_GET_FIN_RANGO('CALIFICACION_EXP', v_cantAniosVincAll);
            END IF;
            /*ELSE
              IF v_ctipper = 1 THEN
                v_nfactp := F_GET_FIN_RANGO('CALIFICACION_EXP_N', v_cantAniosVinculacionClienteP);
              ELSIF v_ctipper = 2 THEN
                v_nfactp := F_GET_FIN_RANGO('CALIFICACION_EXP', v_cantAniosVinculacionClienteP);
              END IF;
            END IF;*/
            -- FIN - TCS_9998 IAXIS-2490 - 24/02/2019 -  JLTS

          RETURN v_nfactp;

        EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_factor_a;

     /**********************************************************************
      FUNCTION f_get_fin_param
      Funcin que consulta el valor de un parametro
      Firma (Specification):
      Param IN  psfinanci: psfinanci
      Param IN    pcparam: pcparam
     **********************************************************************/
       FUNCTION f_get_fin_param(
       psfinanci IN NUMBER,
        pnmovimi IN NUMBER,
         pcparam IN VARCHAR2)
        RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_fin_param';
          num_err             axis_literales.slitera%TYPE := 0;

            v_nvalpar  NUMBER := 0;
            c_nvalpar  NUMBER := 0;

        BEGIN

            SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
              INTO c_nvalpar
              FROM FIN_PARAMETROS
             WHERE SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi
               AND   CPARAM = pcparam;


          IF c_nvalpar > 0 THEN

            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''), to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO v_nvalpar
              FROM FIN_PARAMETROS
             WHERE SFINANCI = psfinanci
               AND  NMOVIMI = pnmovimi
               AND   CPARAM = pcparam;

          ELSE
              v_nvalpar := 0;
          END IF;

          RETURN v_nvalpar;
        EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_fin_param;


     /**********************************************************************
      FUNCTION f_get_fin_rango
      Funcin que consulta el valor de la calificacion propia
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_get_fin_rango(
       pcvariable IN VARCHAR2,
       pnvalor IN NUMBER)
       RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pcvariable = ' || pcvariable || ' pnvalor: ' || pnvalor;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_fin_rango';
          num_err             axis_literales.slitera%TYPE := 0;

              v_ncalpro  NUMBER := 0;

          BEGIN

						-- INI -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la condiciónn de móximo debido al ajuste de la tabla

            SELECT NCALPRO
              INTO v_ncalpro
              FROM FIN_RANGOS f
             WHERE CVARIABLE = pcvariable
               AND    NDESDE <= pnvalor
               AND    NHASTA >= pnvalor
							 AND f.anio = (select max(f1.anio)
                               from fin_rangos f1
															where f1.cvariable = f.cvariable);
            -- Fin -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la condición de máximo debido al ajuste de la tabla

             RETURN v_ncalpro;

          EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_fin_rango;


    /**********************************************************************
      FUNCTION f_get_fin_rango_fijo
      Funcin que consulta el valor de la calificacion propia
      Firma (Specification):
      Param IN  psfinanci: psfinanci
     **********************************************************************/
       FUNCTION f_get_fin_rango_fijo(
       pcvariable IN VARCHAR2,
       ptvalor IN VARCHAR2)
       RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pcvariable = ' || pcvariable || ' ptvalor: ' || ptvalor;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_fin_rango_fijo';
          num_err             axis_literales.slitera%TYPE := 0;

              v_ncalpro  NUMBER := 0;

          BEGIN


            -- INI -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable MAX_CUPOS_SUGER (Máximo cupo sugerido de empresas)
            SELECT NCALPRO
              INTO v_ncalpro
              FROM FIN_RANGOS f
             WHERE CVARIABLE = PCVARIABLE
               AND TRANGO = ptvalor
               AND f.anio = (select max(f1.anio)
                               from fin_rangos f1
                              where f1.cvariable = f.cvariable);
					  -- FIN -IAXIS-4143 -JLTS - 24/05/2019 Se adiciona la variable MAX_CUPOS_SUGER (Máximo cupo sugerido de empresas)


             RETURN v_ncalpro;

          EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_fin_rango_fijo;


     /**********************************************************************
      FUNCTION f_get_cifin_intermedio
      Funcin que retorna los datos de cifin intermenio.
      Param IN  pctipide  : ctipide
      Param IN  pnnumide  : snnumide
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_cifin_intermedio(
        pctipide IN NUMBER,
        pnnumide IN VARCHAR2
          )
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_financiera.f_get_cifin_intermedio';
      vparam         VARCHAR2(500) := 'parámetros - pctipide: ' || pctipide || ' - pnnumide: '  || pnnumide;
      vpasexec       NUMBER := 1;

          sperrep VARCHAR2(500);

          tipo_id  NUMBER := 0;


       BEGIN

      --    IF pnnumide = 36 THEN
      --         tipo_id := 1;
      --    END IF;


          OPEN v_cursor FOR
               SELECT   ci.id_carga, ci.f_carga, ci.tipo_id, ci.no_id, ci.digito_dq,
                        ci.razon_social, ci.apellido1_dq, ci.apellido2_dq, ci.nombre1_dq, ci.nombre2_dq,
                        ci.codigo_pais, ci.fecha_expedicion, ci.ciudad_expedicion, ci.depto_expedicion, ci.codigo_ciudad,
                        ci.codigo_depto, ci.estado_dto, ci.rango_edad, ci.codigo_ciiu, ci.actividad_economica,
                        ci.genero, ci.ubicacion_direccion_1, ci.direccion_1, ci.ciudad1_1, ci.depto1_1,
                        ci.codigo_ciudad1_1, ci.codigo_depto1_1, ci.fecha_ult1_reporte_1, ci.ubicacion_telefono_1, ci.telefono_1,
                        ci.ciudad2_1, ci.depto2_1, ci.codigo_ciudad2_1, ci.codigo_depto2_1, ci.fecha_ult2_reporte_1,
                        ci.celular_1, ci.fecha_ult3_reporte_1, ci.correo_1, ci.fecha_ult4_reporte_1, ci.ubicacion_direccion_2,
                        ci.direccion_2, ci.ciudad1_2, ci.depto1_2, ci.codigo_ciudad2_2, ci.codigo_depto1_2,
                        ci.fecha_ult1_reporte_2, ci.ubicacion_telefono_2, ci.telefono_2, ci.ciudad2_2, ci.depto2_2,
                        ci.codigo_ciudad1_2, ci.codigo_depto2_2, ci.fecha_ult2_reporte_2, ci.celular_2, ci.fecha_ult3_reporte_2,
                        ci.correo_2, ci.fecha_ult4_reporte_2, ci.ubicacion_direccion_3, ci.direccion_3, ci.ciudad1_3,
                        ci.depto1_3, ci.codigo_ciudad1_3, ci.codigo_depto1_3, ci.fecha_ult1_reporte_3, ci.ubicacion_telefono_3,
                        ci.telefono_3, ci.ciudad2_3, ci.depto2_3, ci.codigo_ciudad2_3, ci.codigo_depto2_3,
                        ci.fecha_ult2_reporte_3, ci.celular_3, ci.fecha_ult3_reporte_3, ci.correo_3, ci.fecha_ult4_reporte_3,
                        ci.ingreso_min_probable, ci.capacidad_pago, ci.capacidad_endeuda, ci.endeuda_total_sfinanciero, ci.sumatoria_calif_a,
                        ci.sumatoria_calif_b, ci.sumatoria_calif_c, ci.sumatoria_calif_d, ci.sumatoria_calif_e, ci.sum_con_ult_6_meses,
                        ci.puntaje_score, ci.prob_mora, ci.prob_incumplimiento
                 FROM CIFIN_INTERMEDIO ci
                WHERE
                  --  ci.tipo_id = tipo_id
                  -- AND
                  ci.no_id = TO_NUMBER(pnnumide)
                  AND ci.f_carga = (select max(ci_a.F_CARGA)
                                      from CIFIN_INTERMEDIO ci_a
                                     where ci_a.no_id = TO_NUMBER(pnnumide))
                     --                where ci_a.tipo_id = tipo_id
                     --                  and   ci_a.no_id = pnnumide)
          AND ci.DESC_CARGA != 'CARGA FICHERO';

          RETURN v_cursor;
       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                         SQLERRM || ' ' || SQLCODE);

             IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
             END IF;

             RETURN v_cursor;
       END f_get_cifin_intermedio;


         /**********************************************************************
      FUNCTION f_get_int_carga_informacol
      Funcin que retorna los datos de informa colombia.
      Param IN  pnit  : nit
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
              FUNCTION f_get_int_carga_informacol(
        pnit IN VARCHAR2)
        RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_financiera.f_get_int_carga_informacol';
      vparam         VARCHAR2(500) := 'parmetros - pnit: ' || pnit;
      vpasexec       NUMBER := 1;

          sperrep VARCHAR2(500);

       BEGIN
          OPEN v_cursor FOR
 SELECT ici.proceso, ici.nlinea, ici.ncarga, ici.tipo_oper, ici.nit,
                      ici.nombre, ici.tiposociedad, ici.reprelegal, ici.revfiscal, ici.estempresa,
                      ici.objsocial, ici.fechacons, ici.vigsociedad, ici.limreplegal, ici.incjudicial,
                      ici.nomaccionista1, ici.nomaccionista2, ici.nomaccionista3, ici.nomaccionista4, ici.nitaccionista1,
                      ici.nitaccionista2, ici.nitaccionista3, ici.nitaccionista4, ici.partaccionista1, ici.partaccionista2,
                      ici.partaccionista3, ici.partaccionista4, ici.ciiu, ici.fuenteinf, ici.moneda,
                      ici.valmiles, ici.fecestfinan,
                      to_number(ici.ventas, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') ventas,
                      to_number(ici.ventasperant, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') ventasperant,
                      to_number(ici.costoventas, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') costoventas,
                      to_number(ici.gastosadm, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') gastosadm,
                      to_number(ici.utloperacional, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') utloperacional,
                      to_number(ici.gastosfinan, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') gastosfinan,
                      to_number(ici.resultantimp, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') resultantimp,
                      to_number(ici.utlneta, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') utlneta,
                      to_number(ici.inventario, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') inventario,
                      to_number(ici.cartcliente, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') cartcliente,
                      to_number(ici.actcorriente, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') actcorriente,
                      to_number(ici.totactnocorriente, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') totactnocorriente,
                      to_number(ici.propplanequipo, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') propplanequipo,
                      to_number(ici.otrosactivos, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') otrosactivos,
                      to_number(ici.activototal, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') activototal,
                      to_number(ici.obligfinancp, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') obligfinancp,
                      to_number(ici.proveedorescp, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') proveedorescp,
                      to_number(ici.anticipocp, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') anticipocp,
                      to_number(ici.pascorriente, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') pascorriente,
                      to_number(ici.obligfinanlp, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') obligfinanlp,
                      to_number(ici.anticipolp, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') anticipolp,
                      to_number(ici.totpascorriente, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') totpascorriente,
                      to_number(ici.pastotal, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') pastotal,
                      to_number(ici.patriperant, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') patriperant,
                      to_number(ici.patrianoact, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') patrianoact,
                      to_number(ici.capsocial, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') capsocial,
                      to_number(ici.pricolacc, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') pricolacc,
                      to_number(ici.invsuplcap, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') invsuplcap,
                      to_number(ici.reslegal, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') reslegal,
                      to_number(ici.resocasional, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') resocasional,
                      to_number(ici.resejerant, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') resejerant,
                      to_number(ici.valorizacion, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') valorizacion,
		      /* Changes for IAXIS-4945 PK-01/08/2019 - Start */
                      to_number(ici.patriliquido, '999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS='',.''') patriliquido,
                      ici.feccamcomercio,
                      ici.fotrut, ici.fecrut, ici.fotcedula, ici.fecexpcedula, ici.ciuexpcedula,
                      ici.feccordeclrenta, /*ici.patriliquido,*/ ici.renliqgrav
                      /* Changes for IAXIS-4945 PK-01/08/2019 - End */
                 FROM INT_CARGA_INFORMACOL ici
                WHERE ici.nit = pnit
                  AND ici.origencarga = 'WBS'
                  AND ici.proceso =  (SELECT MAX(icis.PROCESO)
                                        FROM INT_CARGA_INFORMACOL icis
                                       WHERE icis.nit = pnit
                                         AND icis.origencarga = 'WBS');

           --CSUAREZ -I Carga de datos informa colombia en axisfic002 Informacion gral ficha tecnica
           P_UPDATE_FIN_GRAL_TO_INFORMA(pnit);
            --CSUAREZ -F

          RETURN v_cursor;
       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                         SQLERRM || ' ' || SQLCODE);

             IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
             END IF;

             RETURN v_cursor;
       END f_get_int_carga_informacol;

     /**********************************************************************
      FUNCTION F_GET_FIN_INDICA_SECTOR
      Funcin que retorna los datos de los indicadores del sector.
      Param IN  psfinanci  : sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_fin_indica_sector(
         psfinanci IN NUMBER,
          pcmonori IN VARCHAR2,
          pcmondes IN VARCHAR2)
         RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_financiera.f_get_fin_indica_sector';
      vparam         VARCHAR2(500) := 'parmetros - psfinanci: ' || psfinanci;
      vpasexec       NUMBER := 1;


       BEGIN

          OPEN v_cursor FOR
               SELECT fis.cciiu, fis.nmovimi, fis.imargen, fis.icaptrab, fis.trazcor,
                      fis.tprbaci, fis.ienduada, fis.ndiacar, fis.nrotpro, fis.nrotinv,
                      fis.ndiacicl, fis.irentab, fis.ioblcp, fis.iobllp, fis.igastfin,
                      fis.ivalpt
                 FROM FIN_INDICA_SECTOR fis
                WHERE fis.cciiu in (SELECT CCIIU
                                      FROM FIN_GENERAL
                                     WHERE SFINANCI = PSFINANCI);

          RETURN v_cursor;

       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                         SQLERRM || ' ' || SQLCODE);

             IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
             END IF;

             RETURN v_cursor;
       END f_get_fin_indica_sector;


     /**********************************************************************
      FUNCTION F_GET_CIIU
      Funcin que consulta el valor de CIIU
      Firma (Specification):
      Param IN  psfinanci: sfinanci
     **********************************************************************/
       FUNCTION f_get_ciiu(
          psfinanci IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_ciiu';
          num_err             axis_literales.slitera%TYPE := 0;

            v_ciiu  NUMBER := null;

        BEGIN

            SELECT CCIIU
              INTO v_ciiu
              FROM FIN_GENERAL
             WHERE SFINANCI = PSFINANCI;


          RETURN v_ciiu;

        EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_ciiu;


     /**********************************************************************
      FUNCTION F_GET_NIT
      Funcin que consulta el valor de NIT
      Firma (Specification):
      Param IN  psfinanci: sfinanci
     **********************************************************************/
       FUNCTION f_get_nit(
          psfinanci IN NUMBER)
          RETURN VARCHAR2 IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_nit';
          num_err             axis_literales.slitera%TYPE := 0;

            v_nit  VARCHAR2(50) := 0;

        BEGIN

            SELECT NNUMIDE
              INTO v_nit
              FROM PER_PERSONAS
             WHERE SPERSON IN (SELECT SPERSON
                                 FROM FIN_GENERAL
                                WHERE SFINANCI = PSFINANCI);


          RETURN v_nit;

        EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_nit;


     /**********************************************************************
      FUNCTION F_GET_UTLOPERACIONAL
      Funcin que consulta el valor del indicador UTLOPERACIONAL
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_utloperacional(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pciiu = ' || pciiu;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_utloperacional';
          num_err             axis_literales.slitera%TYPE := 0;

            v_utloperacional  NUMBER := 0;

        BEGIN

            SELECT NUTOPAC
              INTO v_utloperacional
              FROM FIN_CIFRAS_SECTORIALES
             WHERE NCOCIIU = PCIIU
               AND FEFECTO =  (SELECT FP.FVALPAR
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN');

          RETURN v_utloperacional;

        EXCEPTION
            WHEN OTHERS THEN
               --ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_utloperacional;


     /**********************************************************************
      FUNCTION F_GET_VENTAS
      Funcin que consulta el valor del indicador VENTAS
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_ventas(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pciiu = ' || pciiu;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_ventas';
          num_err             axis_literales.slitera%TYPE := 0;

            v_ventas  NUMBER := 0;

        BEGIN

             SELECT NVENACT
              INTO v_ventas
              FROM FIN_CIFRAS_SECTORIALES
             WHERE NCOCIIU = PCIIU
               AND FEFECTO  = (SELECT FP.FVALPAR
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN');

          RETURN v_ventas;

        EXCEPTION
            WHEN OTHERS THEN
              -- ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_ventas;


     /**********************************************************************
      FUNCTION F_GET_ACTCORRIENTE
      Funcin que consulta el valor del indicador ACTCORRIENTE
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_actcorriente(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pciiu = ' || pciiu;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_actcorriente';
          num_err             axis_literales.slitera%TYPE := 0;

            v_actcorriente  NUMBER := 0;

        BEGIN

            SELECT NACCOAC
              INTO v_actcorriente
              FROM FIN_CIFRAS_SECTORIALES
             WHERE NCOCIIU = PCIIU
               AND FEFECTO =  (SELECT FP.FVALPAR
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN');


          RETURN v_actcorriente;

        EXCEPTION
            WHEN OTHERS THEN
               --ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_actcorriente;


     /**********************************************************************
      FUNCTION F_GET_PASCORRIENTE
      Funcin que consulta el valor del indicador PASCORRIENTE
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_pascorriente(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pciiu = ' || pciiu;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_pascorriente';
          num_err             axis_literales.slitera%TYPE := 0;

            v_pascorriente  NUMBER := 0;

        BEGIN

            SELECT NPACOAC
              INTO v_pascorriente
              FROM FIN_CIFRAS_SECTORIALES
             WHERE NCOCIIU = PCIIU
               AND FEFECTO  = (SELECT FP.FVALPAR
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN');


          RETURN v_pascorriente;

        EXCEPTION
            WHEN OTHERS THEN
               --ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_pascorriente;


     /**********************************************************************
      FUNCTION F_GET_INVENTARIO
      Funcin que consulta el valor del indicador INVENTARIO
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_inventario(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pciiu = ' || pciiu;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_inventario';
          num_err             axis_literales.slitera%TYPE := 0;

            v_inventario  NUMBER := 0;

        BEGIN

            SELECT NINVEAC
              INTO v_inventario
              FROM FIN_CIFRAS_SECTORIALES
             WHERE NCOCIIU = PCIIU
               AND FEFECTO =  (SELECT FP.FVALPAR
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN');


          RETURN v_inventario;

        EXCEPTION
            WHEN OTHERS THEN
               --ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_inventario;

     /**********************************************************************
      FUNCTION F_GET_PASTOTAL
      Funcin que consulta el valor del indicador PASTOTAL
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_pastotal(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pciiu = ' || pciiu;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_pastotal';
          num_err             axis_literales.slitera%TYPE := 0;

            v_pastotal  NUMBER := 0;

        BEGIN

            SELECT NTOPAAC
              INTO v_pastotal
              FROM FIN_CIFRAS_SECTORIALES
             WHERE NCOCIIU = PCIIU
               AND FEFECTO = (SELECT FP.FVALPAR
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN');


          RETURN v_pastotal;

        EXCEPTION
            WHEN OTHERS THEN
               --ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_pastotal;


     /**********************************************************************
      FUNCTION F_GET_ACTIVOTOTAL
      Funcin que consulta el valor del indicador ACTIVOTOTAL
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_activototal(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pciiu = ' || pciiu;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_activototal';
          num_err             axis_literales.slitera%TYPE := 0;

            v_activototal  NUMBER := 0;

        BEGIN

            SELECT NTOACAC
              INTO v_activototal
              FROM FIN_CIFRAS_SECTORIALES
             WHERE NCOCIIU = PCIIU
               AND FEFECTO =  (SELECT FP.FVALPAR
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN');

          RETURN v_activototal;

        EXCEPTION
            WHEN OTHERS THEN
              -- ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_activototal;


     /**********************************************************************
      FUNCTION F_GET_CARTCLIENTE
      Funcin que consulta el valor del indicador CARTCLIENTE
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_cartcliente(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pciiu = ' || pciiu;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_cartcliente';
          num_err             axis_literales.slitera%TYPE := 0;

            v_cartcliente  NUMBER := 0;

        BEGIN


            SELECT NCUCOAC   -- preguntar  a APOL
              INTO v_cartcliente
              FROM FIN_CIFRAS_SECTORIALES
             WHERE NCOCIIU = PCIIU
               AND FEFECTO = (SELECT FP.FVALPAR
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN');


          RETURN v_cartcliente;

        EXCEPTION
            WHEN OTHERS THEN
               --ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_cartcliente;


     /**********************************************************************
      FUNCTION F_GET_PROVEEDORESCP
      Funcin que consulta el valor del indicador PROVEEDORESCP
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_proveedorescp(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pciiu = ' || pciiu;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_proveedorescp';
          num_err             axis_literales.slitera%TYPE := 0;

            v_proveedorescp  NUMBER := 0;

        BEGIN

            SELECT NPROVAC
              INTO v_proveedorescp
              FROM FIN_CIFRAS_SECTORIALES
             WHERE NCOCIIU = PCIIU
               AND FEFECTO = (SELECT FP.FVALPAR
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN');


          RETURN v_proveedorescp;

        EXCEPTION
            WHEN OTHERS THEN
               --ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_proveedorescp;


     /**********************************************************************
      FUNCTION F_GET_COSTOVENTAS
      Funcin que consulta el valor del indicador COSTOVENTAS
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_costoventas(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pciiu = ' || pciiu;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_costoventas';
          num_err             axis_literales.slitera%TYPE := 0;

            v_costoventas  NUMBER := 0;

        BEGIN

            SELECT NCOVEAC
              INTO v_costoventas
              FROM FIN_CIFRAS_SECTORIALES
             WHERE NCOCIIU = PCIIU
               AND FEFECTO = (SELECT FP.FVALPAR
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN');


          RETURN v_costoventas;

        EXCEPTION
            WHEN OTHERS THEN
               --ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_costoventas;


     /**********************************************************************
      FUNCTION F_GET_UTLNETA
      Funcin que consulta el valor del indicador UTLNETA
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_utlneta(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pciiu = ' || pciiu;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_utlneta';
          num_err             axis_literales.slitera%TYPE := 0;

            v_utlneta  NUMBER := 0;

        BEGIN

            SELECT NUTNEAC
              INTO v_utlneta
              FROM FIN_CIFRAS_SECTORIALES
             WHERE NCOCIIU = PCIIU
               AND FEFECTO = (SELECT FP.FVALPAR
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN');


          RETURN v_utlneta;

        EXCEPTION
            WHEN OTHERS THEN
               --ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_utlneta;

     /**********************************************************************
      FUNCTION F_GET_OBLIGFINANCP
      Funcin que consulta el valor del indicador OBLIGFINANCP
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_obligfinancp(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pciiu = ' || pciiu;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_obligfinancp';
          num_err             axis_literales.slitera%TYPE := 0;

            v_obligfinancp  NUMBER := 0;

        BEGIN

            SELECT NOBFIAC  -- preguntar APOL
              INTO v_obligfinancp
              FROM FIN_CIFRAS_SECTORIALES
             WHERE NCOCIIU = PCIIU
               AND FEFECTO = (SELECT FP.FVALPAR
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN');

          RETURN v_obligfinancp;

        EXCEPTION
            WHEN OTHERS THEN
               --ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_obligfinancp;


     /**********************************************************************
      FUNCTION F_GET_OBLIGFINANLP
      Funcin que consulta el valor del indicador OBLIGFINANLP
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_obligfinanlp(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pciiu = ' || pciiu;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_obligfinanlp';
          num_err             axis_literales.slitera%TYPE := 0;

            v_obligfinanlp  NUMBER := 0;

        BEGIN

            SELECT NOBFIAC  -- preguntar APOL
              INTO v_obligfinanlp
              FROM FIN_CIFRAS_SECTORIALES
             WHERE NCOCIIU = PCIIU
               AND FEFECTO = (SELECT FP.FVALPAR
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN');


          RETURN v_obligfinanlp;

        EXCEPTION
            WHEN OTHERS THEN
              -- ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_obligfinanlp;


     /**********************************************************************
      FUNCTION F_GET_GASTOSFINAN
      Funcin que consulta el valor del indicador GASTOSFINAN
      Firma (Specification):
      Param IN  pciiu: ciiu
     **********************************************************************/
       FUNCTION f_get_gastosfinan(
          pciiu IN NUMBER,
      psfinanci IN NUMBER,
       pnmovimi IN NUMBER)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'pciiu = ' || pciiu;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_gastosfinan';
          num_err             axis_literales.slitera%TYPE := 0;

            v_gastosfinan  NUMBER := 0;

        BEGIN

            SELECT NREEJAC
              INTO v_gastosfinan
              FROM FIN_CIFRAS_SECTORIALES
             WHERE NCOCIIU = PCIIU
               AND FEFECTO = (SELECT FP.FVALPAR
                                 FROM FIN_PARAMETROS FP
                                WHERE FP.SFINANCI = psfinanci
                                  AND FP.NMOVIMI = pnmovimi
                                  AND CPARAM = 'FECHA_EST_FIN');



          RETURN v_gastosfinan;

        EXCEPTION
            WHEN OTHERS THEN
               --ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_gastosfinan;


     /**********************************************************************
      FUNCTION F_GET_ITASA
      Funcin que consulta el valor de ITASA
      Firma (Specification):
      Param IN  psfinanci: sfinanci
     **********************************************************************/
       FUNCTION f_get_itasa(
          psfinanci IN NUMBER,
          pnmovimi IN NUMBER,
          pcmonori IN VARCHAR2,
          pcmondes IN VARCHAR2,
           pcparam IN VARCHAR2)
          RETURN NUMBER IS
          vpasexec            NUMBER(8) := 1;
          vparam              VARCHAR2(2000) := 'psfinanci = ' || psfinanci;
          terror              VARCHAR2(2000);
          vobject             VARCHAR2(200) := 'pac_financiera.f_get_itasa';
          num_err             axis_literales.slitera%TYPE := 0;
          v_itasa  NUMBER := 0;

        BEGIN

              SELECT NVL(MAX(e.itasa),1) contador
                INTO v_itasa
                FROM ECO_TIPOCAMBIO e
               WHERE  e.CMONORI = pcmonori
                 AND  e.CMONDES = pcmondes
                 AND  e.FCAMBIO = (SELECT FVALPAR
                                     FROM FIN_PARAMETROS
                                    WHERE CPARAM = pcparam
                                      AND SFINANCI = psfinanci
                                      AND  NMOVIMI = pnmovimi);

          RETURN v_itasa;

        EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               num_err := 9907950;  --falta add literal
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
               RETURN num_err;
       END f_get_itasa;



      FUNCTION f_modificar_cciiu(
     psfinanci IN NUMBER,
        pcciiu IN NUMBER,
      mensajes OUT T_IAX_MENSAJES )

      RETURN NUMBER IS
             vobjectname VARCHAR2(100) := 'pac_financiera.f_get_itasa';
             --INI 1554 CESS
             PSPERSON VARCHAR2(12) ;
			 /* Cambios de  tarea IAXIS-13044 : start */
             VPERSON_NUM_ID per_personas.nnumide%type;			 
			 /* Cambios de  tarea IAXIS-13044 : end */
             --END 1554 CESS
         -- INI TCS_11;IAXIS-3070 - JLTS - 10/03/2019 - Se agrega la variable v_max_nmovimi
         v_max_nmovimi number := 0;
         -- FIN TCS_11;IAXIS-3070 - JLTS - 10/03/2019
       BEGIN
         -- INI TCS_11;IAXIS-3070 - JLTS - 10/03/2019 - Se agrega la variable v_max_nmovimi
         SELECT MAX(d1.nmovimi) INTO v_max_nmovimi FROM fin_general_det d1 WHERE d1.sfinanci = psfinanci;
         -- FIN TCS_11;IAXIS-3070 - JLTS - 10/03/2019

         UPDATE fin_general SET cciiu = pcciiu WHERE sfinanci = psfinanci;
         -- INI TCS_11;IAXIS-3070 - JLTS - 10/03/2019 - Se adiciona UPDATE para actualizar al mximo registro de FIN_GENERAL_DET
         UPDATE (SELECT fg.cciiu AS old_cciiu, fgd.cciiu AS new_cciiu
                    FROM fin_general fg
                   INNER JOIN fin_general_det fgd
                      ON fg.sfinanci = fgd.sfinanci
                   WHERE fg.sfinanci = psfinanci
                     AND fgd.nmovimi = v_max_nmovimi)
            SET old_cciiu = new_cciiu;
         -- FIN TCS_11;IAXIS-3070 - JLTS - 10/03/2019
 --INI 1554 CESS
          SELECT SPERSON  INTO PSPERSON FROM FIN_GENERAL WHERE sfinanci = psfinanci;

	   /* CAMBIOS DE SWAPNIL PARA CONVIVENCIA :START */       
		   BEGIN
			 SELECT PP.NNUMIDE
			   INTO VPERSON_NUM_ID
			   FROM PER_PERSONAS PP
			  WHERE PP.SPERSON = PSPERSON;
		   
			 PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
											   1,
											   'S03502',
											   NULL);
		   EXCEPTION
				WHEN OTHERS
				THEN
				 p_tab_error (f_sysdate,
							  f_user,
							  'PAC_FINANCIERA.f_modificar_cciiu',
							  1,
							  'Error PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
							  SQLERRM
							 );                                                            												  
			    END;
       /* CAMBIOS DE SWAPNIL PARA CONVIVENCIA :END */
--END 1554 CESS

        RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor', SQLERRM || ' ' || SQLCODE);
           RETURN SQLCODE;
      END f_modificar_cciiu;


     /**********************************************************************
      FUNCTION F_GET_PERSONA_FIN
      Funcin que retorna los datos deL tipo de persona.
      Param IN  psfinanci: sfinanci
      Param OUT PRETCURSOR : SYS_REF_CURSOR
     **********************************************************************/
      FUNCTION f_get_persona_fin(
        psfinanci IN NUMBER)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_financiera.f_get_persona_fin';
      vparam         VARCHAR2(500) := 'parmetros - psfinanci: ' || psfinanci;
      vpasexec       NUMBER := 1;
       BEGIN
          OPEN v_cursor FOR

            SELECT CTIPPER, CTIPIDE
              FROM PER_PERSONAS
             WHERE SPERSON = (SELECT SPERSON
                                FROM FIN_GENERAL
                               WHERE SFINANCI = PSFINANCI);
          RETURN v_cursor;
       EXCEPTION
          WHEN OTHERS THEN
             p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor',
                         SQLERRM || ' ' || SQLCODE);

             IF v_cursor%ISOPEN THEN
                CLOSE v_cursor;
             END IF;

             RETURN v_cursor;
       END f_get_persona_fin;

/**********************************************************************
     PROCEDURE P_UPDATE_FIN_GRAL_TO_INFORMA
      Procedimiento que actualiza los datos correspondientes a la informacin general de la ficha financiera encontrada a travs del WS de Informa Colombia
      Param IN  pnit  : nit
      Fecha y Usuario Creacion: 21/11/2018 - csuarez
      Fecha  y Usuario Modificaciones:

     **********************************************************************/
PROCEDURE P_UPDATE_FIN_GRAL_TO_INFORMA( pnit IN VARCHAR2) IS
  vobjectname VARCHAR2(500) := 'pac_financiera.P_UPDATE_FIN_GRAL_TO_INFORMA';
  vparam      VARCHAR2(500) := 'pnit: ' || pnit;
  /*Variables de fin_general para validar que ya no existan datos.*/
  dfeccam_gral    DATE;
  vobjsoc_gral    VARCHAR2(2000);
  dfecconsti_gral DATE;
  vvigsoc_gral    VARCHAR2(2000);
  /*Variables de INT_CARGA_INFORMACOL para obtener los datos que existan.*/
  dfeccam_informa    DATE;
  vobjsoc_informa    VARCHAR2(2000);
  dfecconsti_informa DATE;
  vvigsoc_informa    VARCHAR2(2000);
--INI 1554 CESS
  PSPERSON VARCHAR2(12) ;
--END 1554 CESS
BEGIN

  /*FIN_GENERAL*/
  BEGIN
    SELECT FCCOMER,
      TOBJSOC,
      TVIGENC,
      FCONSTI,
 --INI 1554 CESS
 SPERSON
  --END 1554 CESS
    INTO dfeccam_gral,
      vobjsoc_gral,
      vvigsoc_gral,
      dfecconsti_gral,
       --INI 1554 CESS
      PSPERSON
       --END 1554 CESS
    FROM FIN_GENERAL
    WHERE SPERSON =
      (SELECT SPERSON FROM PER_PERSONAS WHERE NNUMIDE= pnit
      );
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dfeccam_gral    := NULL;
    vobjsoc_gral    := NULL;
    vvigsoc_gral    := NULL;
    dfecconsti_gral := NULL;
  END;

  /*INT_CARGA_INFORMACOL*/
  BEGIN
    SELECT TO_DATE(FECCAMCOMERCIO, 'DD/MM/YYYY'),
      RTRIM(SUBSTR(OBJSOCIAL,0, 2000)),
      VIGSOCIEDAD,
      TO_DATE(FECHACONS, 'DD/MM/YYYY')
    INTO dfeccam_informa,
      vobjsoc_informa,
      vvigsoc_informa,
      dfecconsti_informa
    FROM INT_CARGA_INFORMACOL ici
    WHERE ici.nit       = pnit
    AND ici.origencarga = 'WBS'
    AND ici.proceso     =
      (SELECT MAX(icis.PROCESO)
      FROM INT_CARGA_INFORMACOL icis
      WHERE icis.nit       = pnit
      AND icis.origencarga = 'WBS'
      );
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dfeccam_informa    := NULL;
    vobjsoc_informa    := NULL;
    vvigsoc_informa    := NULL;
    dfecconsti_informa := NULL;
  END;

  IF dfeccam_informa IS NOT NULL THEN
    dfeccam_gral  := dfeccam_informa;
  END IF;

  IF vobjsoc_informa IS NOT NULL THEN
    vobjsoc_gral  := vobjsoc_informa;
  END IF;

  IF vvigsoc_informa IS NOT NULL THEN
    vvigsoc_gral  := vvigsoc_informa;
  END IF;

  IF dfecconsti_informa IS NOT NULL THEN
    dfecconsti_gral  := dfecconsti_informa;
  END IF;

  UPDATE FIN_GENERAL
  SET TOBJSOC   = vobjsoc_gral,
    TVIGENC     = vvigsoc_gral,
    FCCOMER     = dfeccam_gral,
    FCONSTI     = dfecconsti_gral
  WHERE SPERSON = (SELECT SPERSON FROM PER_PERSONAS WHERE NNUMIDE= pnit);
  --INI 1554 CESS
	/* Cambios de  tarea IAXIS-13044 :START */ 
       BEGIN       
         PAC_CONVIVENCIA.P_SEND_DATA_CONVI(PNIT,
                                           1,
                                           'S03502',
                                           NULL);
		EXCEPTION
				WHEN OTHERS
				THEN
				 p_tab_error (f_sysdate,
							  f_user,
							  'PAC_FINANCIERA.P_UPDATE_FIN_GRAL_TO_INFORMA',
							  1,
							  'Error PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
							  SQLERRM
							 );                                                            												  
			    END;										          
    /* Cambios de  tarea IAXIS-13044 :END */
  --END 1554 CESS
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, USER, vobjectname || ' PARAMS:'||vparam, 0, 'No Update Case', SQLERRM || ' ' || SQLCODE);
END P_UPDATE_FIN_GRAL_TO_INFORMA;

    -- INI - IAXIS-3673 - JLTS - 15/04/2019. Validacin de la ecuacin patrimonial
    /**********************************************************************
      FUNCTION F_VPATRIMONIAL (Validacin patrimonial)
      Funcin que valida la ecuacin patrimonial.
      Param  IN psfinanci: sfinanci
      Param  IN pnmovimi: nmovimi
     **********************************************************************/
      FUNCTION f_vpatrimonial(psfinanci IN NUMBER, pnmovimi IN NUMBER, mensajes IN OUT t_iax_mensajes) 
				RETURN NUMBER IS
        vnumerr  NUMBER(8) := 0;
        vpasexec NUMBER(8) := 1;
        vparam   VARCHAR2(500) := 'parametros  - ' || psfinanci || ' - ' || pnmovimi;
        vobject  VARCHAR2(200) := 'PAC_IAX_FINANCIERA.f_vpatrimonial';

        CURSOR c_indicador(w_sfinanci fin_parametros.sfinanci%TYPE, w_nmovimi fin_parametros.nmovimi%TYPE) IS
          SELECT *
            FROM fin_parametros fp
           WHERE fp.sfinanci = w_sfinanci
             AND fp.nmovimi = w_nmovimi;
        c_indicador_r c_indicador%ROWTYPE;
				vmensaje       VARCHAR2(1000) := 'parmetros sin informar - ';
        e_object_error      EXCEPTION;
				e_param_error       EXCEPTION;
				
        v_rango CONSTANT NUMBER := 100;
        c_act_total        NUMBER := 0;
				v_act_total        number := 0;
        v_act_totalnumber  NUMBER := 0;
        c_pas_corr         NUMBER := 0;
        v_pas_corr         NUMBER := 0;
        c_pas_no_corr      NUMBER := 0;
        v_pas_no_corr      NUMBER := 0;
        c_patri_ano_actual NUMBER := 0;
        v_patri_ano_actual NUMBER := 0;
        c_act_corr         NUMBER := 0;
        v_act_corr         NUMBER := 0;
        c_pas_total        NUMBER := 0;
        v_pas_total        NUMBER := 0;
        c_tot_act_no_corr  NUMBER := 0;
        v_tot_act_no_corr  NUMBER := 0;
	/** Added for IAXIS-4945 by PranayK-30/07/2019 - START */
        c_resv_legal  		NUMBER := 0;
        v_resv_legal  		NUMBER := 0;
        c_cap_social  		NUMBER := 0;
        v_cap_social  		NUMBER := 0;
        c_res_ejer_ant  	NUMBER := 0;
        v_res_ejer_ant  	NUMBER := 0;
        c_prima_accion  	NUMBER := 0;
        v_prima_accion  	NUMBER := 0;
        c_resv_ocasi  		NUMBER := 0;
        v_resv_ocasi  		NUMBER := 0;
        c_asignado  		NUMBER := 0;
        v_asignado  		NUMBER := 0;
        c_patri_liquido  	NUMBER := 0;
        v_patri_liquido  	NUMBER := 0;
        /** Added for IAXIS-4945 by PranayK-30/07/2019 - END */
		
      BEGIN
--        FOR c_indicador_r IN c_indicador(psfinanci, pnmovimi) LOOP
          -- Validacion Activo Total.
          SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
                            to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
            INTO c_act_total
            FROM fin_parametros
           WHERE cparam = 'ACT_TOTAL'
             AND sfinanci = psfinanci
             AND nmovimi = pnmovimi;
          vpasexec := 10;
        
          IF c_act_total > 0 THEN
            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
                        to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO v_act_total
              FROM fin_parametros
             WHERE cparam = 'ACT_TOTAL'
               AND sfinanci = psfinanci
               AND nmovimi = pnmovimi;
            vpasexec := 20;
          END IF;
          -- Validacion Pasivo Total.
          SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
                            to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
            INTO c_pas_corr
            FROM fin_parametros
           WHERE cparam = 'PAS_CORR'
             AND sfinanci = psfinanci
             AND nmovimi = pnmovimi;
          vpasexec := 30;
          IF c_pas_corr > 0 THEN
            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
                        to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO v_pas_corr
              FROM fin_parametros
             WHERE cparam = 'PAS_CORR'
               AND sfinanci = psfinanci
               AND nmovimi = pnmovimi;
          END IF;
        
          SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
                            to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
            INTO c_pas_no_corr
            FROM fin_parametros
           WHERE cparam = 'PAS_NO_CORR'
             AND sfinanci = psfinanci
             AND nmovimi = pnmovimi;
          vpasexec := 40;
          IF c_pas_no_corr > 0 THEN
            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
                        to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO v_pas_no_corr
              FROM fin_parametros
             WHERE cparam = 'PAS_NO_CORR'
               AND sfinanci = psfinanci
               AND nmovimi = pnmovimi; -- CP0507M_SYS_PERS - ACL - 29/11/2018
          END IF;
          -- Validacion Ecuacion Patrimonial
          SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
                            to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
            INTO c_patri_ano_actual
            FROM fin_parametros
           WHERE cparam = 'PATRI_ANO_ACTUAL'
             AND sfinanci = psfinanci
             AND nmovimi = pnmovimi;
          vpasexec := 50;
          IF c_patri_ano_actual > 0 THEN
            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
                        to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO v_patri_ano_actual
              FROM fin_parametros
             WHERE cparam = 'PATRI_ANO_ACTUAL'
               AND sfinanci = psfinanci
               AND nmovimi = pnmovimi;
          END IF;
          SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
                            to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
            INTO c_act_corr
            FROM fin_parametros
           WHERE cparam = 'ACT_CORR'
             AND sfinanci = psfinanci
             AND nmovimi = pnmovimi;
          vpasexec := 60;
          IF c_act_corr > 0 THEN
            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
                        to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO v_act_corr
              FROM fin_parametros
             WHERE cparam = 'ACT_CORR'
               AND sfinanci = psfinanci
               AND nmovimi = pnmovimi;
          END IF;
          SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
                            to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
            INTO c_pas_total
            FROM fin_parametros
           WHERE cparam = 'PAS_TOTAL'
             AND sfinanci = psfinanci
             AND nmovimi = pnmovimi;
          vpasexec := 70;
          IF c_pas_total > 0 THEN
            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
                        to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO v_pas_total
              FROM fin_parametros
             WHERE cparam = 'PAS_TOTAL'
               AND sfinanci = psfinanci
               AND nmovimi = pnmovimi;
          END IF;
          SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
                            to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
            INTO c_tot_act_no_corr
            FROM fin_parametros
           WHERE cparam = 'TOT_ACT_NO_CORR'
             AND sfinanci = psfinanci
             AND nmovimi = pnmovimi;
          vpasexec := 80;
          IF c_tot_act_no_corr > 0 THEN
            SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
                        to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
              INTO v_tot_act_no_corr
              FROM fin_parametros
             WHERE cparam = 'TOT_ACT_NO_CORR'
               AND sfinanci = psfinanci
               AND nmovimi = pnmovimi;
          END IF;
--        END LOOP;
		/** Added for IAXIS-4945 by PranayK-30/07/2019 - START */
		SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
					to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
			INTO c_resv_legal
		FROM fin_parametros
		WHERE cparam = 'RESV_LEGAL'
			AND sfinanci = psfinanci
			AND nmovimi = pnmovimi;
		vpasexec := 150;
		IF c_resv_legal > 0 THEN
			SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
						to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
				INTO v_resv_legal
			FROM fin_parametros
			WHERE cparam = 'RESV_LEGAL'
				AND sfinanci = psfinanci
				AND nmovimi = pnmovimi;
		END IF;
		--
		SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
					to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
			INTO c_cap_social
		FROM fin_parametros
		WHERE cparam = 'CAP_SOCIAL'
			AND sfinanci = psfinanci
			AND nmovimi = pnmovimi;
		vpasexec := 160;
		IF c_cap_social > 0 THEN
			SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
						to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
				INTO v_cap_social
			FROM fin_parametros
			WHERE cparam = 'CAP_SOCIAL'
				AND sfinanci = psfinanci
				AND nmovimi = pnmovimi;
		END IF;
		--
		SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
					to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
			INTO c_res_ejer_ant
		FROM fin_parametros
		WHERE cparam = 'RES_EJER_ANT'
			AND sfinanci = psfinanci
			AND nmovimi = pnmovimi;
		vpasexec := 170;
		IF c_res_ejer_ant > 0 THEN
			SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
						to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
				INTO v_res_ejer_ant
			FROM fin_parametros
			WHERE cparam = 'RES_EJER_ANT'
				AND sfinanci = psfinanci
				AND nmovimi = pnmovimi;
		END IF;
		--
		SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
					to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
			INTO c_prima_accion
		FROM fin_parametros
		WHERE cparam = 'PRIMA_ACCION'
			AND sfinanci = psfinanci
			AND nmovimi = pnmovimi;
		vpasexec := 180;
		IF c_prima_accion > 0 THEN
			SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
						to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
				INTO v_prima_accion
			FROM fin_parametros
			WHERE cparam = 'PRIMA_ACCION'
				AND sfinanci = psfinanci
				AND nmovimi = pnmovimi;
		END IF;
		--
		SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
					to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
			INTO c_resv_ocasi
		FROM fin_parametros
		WHERE cparam = 'RESV_OCASI'
			AND sfinanci = psfinanci
			AND nmovimi = pnmovimi;
		vpasexec := 190;
		IF c_resv_ocasi > 0 THEN
			SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
						to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
				INTO v_resv_ocasi
			FROM fin_parametros
			WHERE cparam = 'RESV_OCASI'
				AND sfinanci = psfinanci
				AND nmovimi = pnmovimi;
		END IF;
		--
		SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
					to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
			INTO c_asignado
		FROM fin_parametros
		WHERE cparam = 'ASIGNADO'
			AND sfinanci = psfinanci
			AND nmovimi = pnmovimi;
		vpasexec := 200;
		IF c_asignado > 0 THEN
			SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
						to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
				INTO v_asignado
			FROM fin_parametros
			WHERE cparam = 'ASIGNADO'
				AND sfinanci = psfinanci
				AND nmovimi = pnmovimi;
		END IF;
		--
		SELECT COUNT(nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
					to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.''')))
			INTO c_patri_liquido
		FROM fin_parametros
		WHERE cparam = 'PATRI_LIQUIDO'
			AND sfinanci = psfinanci
			AND nmovimi = pnmovimi;
		vpasexec := 210;
		IF c_patri_liquido > 0 THEN
			SELECT nvl(to_number(nvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''),
						to_number(tvalpar, '9999999999999D999', 'NLS_NUMERIC_CHARACTERS = '',.'''))
				INTO v_patri_liquido
			FROM fin_parametros
			WHERE cparam = 'PATRI_LIQUIDO'
				AND sfinanci = psfinanci
				AND nmovimi = pnmovimi;
		END IF;
		--
		vpasexec := 220;
		IF ((v_resv_legal + v_cap_social + v_res_ejer_ant + v_prima_accion + v_resv_ocasi + v_asignado) <> v_patri_liquido) THEN
			vnumerr := 89906345;
			pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
		END IF;
		/** Added for IAXIS-4945 by PranayK-30/07/2019 - END */
          vpasexec := 90;
       -- Activo Total debe ser igual a Pasivo Total + Patrimonio.
       IF (V_PAS_TOTAL + V_PATRI_ANO_ACTUAL) > (V_ACT_TOTAL + V_RANGO) OR
          (V_PAS_TOTAL + V_PATRI_ANO_ACTUAL) < (V_ACT_TOTAL - V_RANGO) THEN
         vnumerr := 89906072;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
       END IF;
          vpasexec := 100;
       -- Pasivo Total debe ser igual a Activo Total - Patrimonio.
       IF (V_ACT_TOTAL - V_PATRI_ANO_ACTUAL) > (V_PAS_TOTAL + V_RANGO) OR
          (V_ACT_TOTAL - V_PATRI_ANO_ACTUAL) < (V_PAS_TOTAL - V_RANGO) THEN
         vnumerr := 89906073;
				 pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
       END IF;
          vpasexec := 110;
       -- Patrimonio debe ser igual a Activo Total - Pasivo Total.
       IF (V_ACT_TOTAL - V_PAS_TOTAL) > (V_PATRI_ANO_ACTUAL + V_RANGO) OR
          (V_ACT_TOTAL - V_PAS_TOTAL) < (V_PATRI_ANO_ACTUAL - V_RANGO) THEN
         vnumerr := 89906074;
				 pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
       END IF;
          vpasexec := 120;
       -- Otras validaciones
       -- Activo Corriente + Activo no corriente debe ser igual a Activo Total.
       IF (V_ACT_CORR + V_TOT_ACT_NO_CORR) > (V_ACT_TOTAL + V_RANGO) OR
          (V_ACT_CORR + V_TOT_ACT_NO_CORR) < (V_ACT_TOTAL - V_RANGO)  THEN
         vnumerr := 89906270;
				 pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
       END IF;
          vpasexec := 130;
       -- Pasivo Corriente + Pasivo no Corriente debe ser igual a Pasivo Total.
       IF (V_PAS_CORR + V_PAS_NO_CORR) < (V_PAS_TOTAL - V_RANGO) OR
				 (V_PAS_CORR + V_PAS_NO_CORR) > (V_PAS_TOTAL + V_RANGO) THEN
         vnumerr := 89906271;
				 pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
       END IF;
       vpasexec := 140;
			 IF vnumerr <> 0 THEN
         RAISE e_object_error;
       END IF;
       RETURN vnumerr;
      
      EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, 
                                           psqcode  => SQLCODE, psqerrm  => SQLERRM);
         RETURN 1;
      END f_vpatrimonial;
       -- FIN - IAXIS-3673 - JLTS - 15/04/2019. Validacin de la ecuacin patrimonial
    -- INI -IAXIS-2099 -19/02/2020
    /******************************************************************************
      NOMBRE:    F_GRAB_AGENDA_NO_INF_FIN
      PROPSITO:  Función ±ue almacena los datos de agenda de una persona cuando no tiene información 
                 financiera actualizada.
                 El último indicador financiero, se validara después del cuarto mes del año, es decir, en 
                 el de mayo la información financiera deberá estar al año inmediatamente anterior.

      PARAMETROS:

           return            : 0 -> Todo correcto
                               1 -> Se ha producido un error

    *****************************************************************************/
    FUNCTION f_grab_agenda_no_inf_fin(psperson IN NUMBER,
                                      mensajes IN OUT t_iax_mensajes)
    
     RETURN NUMBER IS
    
      v_retorno      NUMBER(1) := 0;
      v_existe       NUMBER(1) := 0;
      v_inserta      NUMBER(1) := 0;
      v_idapunte_out agd_agenda.idapunte%TYPE;
      v_fecha_val CONSTANT DATE := add_months(trunc(f_sysdate, 'YYYY'), 3); -- Se valida al mes de abril
      --
      TYPE two_cols_rt IS RECORD(
        idagenda agd_agenda.idagenda%TYPE,
        idapunte agd_agenda.idapunte%TYPE);
    
      TYPE agenda_info_t IS TABLE OF two_cols_rt;
      --
      l_agenda    agenda_info_t;
      vobjectname VARCHAR2(100) := 'PAC_FINANCIERA.F_GRAB_AGENDA_NO_INF_FIN';
      vnumerr     NUMBER := 0;
      e_object_error EXCEPTION;
    BEGIN
      -- Valida información ¤e año ©nmediatamente anterior
      SELECT CASE
               WHEN q1.max_finan = q1.v_anio_anterior THEN
                0
               ELSE
                CASE
                  WHEN to_number(to_char(q1.v_anio_anterior, 'YYYY')) - to_number(to_char(q1.max_finan, 'YYYY')) > 1 THEN
                   1
                  ELSE
                   CASE
                     WHEN hoy > q1.v_fecha_val THEN
                      1
                     ELSE
                      0
                   END
                END
             END v_inserta
        INTO v_inserta
        FROM (SELECT trunc(f_sysdate, 'MM') hoy,
                     v_fecha_val v_fecha_val,
                     trunc(MAX(i.findicad), 'YYYY') max_finan,
                     trunc(add_months(f_sysdate, -12), 'YYYY') v_anio_anterior
                FROM fin_indicadores i
               WHERE EXISTS (SELECT 1
                        FROM fin_general f
                       WHERE f.sfinanci = i.sfinanci
                         AND f.sperson = psperson)) q1;
      -- Verifica que exista la informacióm para ese apunte en específico
      SELECT COUNT(1)
        INTO v_existe
        FROM agd_agenda ap,
             agd_apunte agd
       WHERE ap.idapunte = agd.idapunte
         AND ap.cclagd IN (3, 4)
         AND ap.tclagd = psperson
         AND agd.ttitapu = f_axis_literales(89907104, 8);
    
      IF v_inserta = 1 THEN
        IF v_existe = 0 THEN
          vnumerr := pac_md_agenda.f_set_agenda(NULL, NULL, 4,
                                                -- Personas
                                                psperson,
                                                -- SPERSON
                                                2, 0, NULL, NULL, f_axis_literales(89907104, 8), f_axis_literales(89907104, 8), 0,
                                                -- Automático
                                                NULL, NULL, NULL, f_user, NULL, f_sysdate, NULL, NULL, NULL, NULL, NULL,
                                                v_idapunte_out, mensajes, NULL);
          IF vnumerr != 0 THEN
            RAISE e_object_error;
          END IF;
        END IF;
      ELSE
        IF v_existe > 0 THEN
          SELECT g.idagenda,
                 g.idapunte
            BULK COLLECT
            INTO l_agenda
            FROM agd_agenda g,
                 agd_apunte a
           WHERE g.idapunte = a.idapunte
             AND g.cclagd = 4
             AND g.tclagd = psperson
             AND a.ttitapu = f_axis_literales(89907104, 8);
          IF l_agenda.count > 0 THEN
            FOR l_age IN l_agenda.first .. l_agenda.last LOOP
              -- Como ya existe y no se debe estar, se borra
              DELETE FROM agd_movagenda m
               WHERE m.idagenda = l_agenda(l_age).idagenda
                 AND m.idapunte = l_agenda(l_age).idapunte;
              --
              DELETE FROM agd_movapunte m WHERE m.idapunte = l_agenda(l_age).idapunte;
              --
              DELETE FROM agd_agenda m
               WHERE m.idagenda = l_agenda(l_age).idagenda
                 AND m.idapunte = l_agenda(l_age).idapunte;
              --
              DELETE FROM agd_apunte m WHERE m.idapunte = l_agenda(l_age).idapunte;
            END LOOP;
          END IF;
        END IF;
      END IF;
      RETURN 0;
    EXCEPTION
      WHEN e_object_error THEN
        p_tab_error(f_sysdate, USER, vobjectname, 0, 'PAC_MD_AGENDA.F_SET_AGENDA', 'ERROR');
        ROLLBACK;
        RETURN 1;
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, USER, vobjectname, 0, 'OTHERS cursor', SQLERRM || ' ' || SQLCODE);
        RETURN SQLCODE;
    END f_grab_agenda_no_inf_fin;
    -- FIN -IAXIS-2099 -19/02/2020
END pac_financiera;
/
