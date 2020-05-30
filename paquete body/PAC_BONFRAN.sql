create or replace PACKAGE BODY pac_bonfran IS
/******************************************************************************
   NOMBRE    : PAC_BONFRAN
   ARCHIVO   : PAC_BONFRAN_BDY.sql
   PROP¿SITO : Package con funciones propias de la funcionalidad de Franquicias.

   REVISIONES:
   Ver    Fecha      Autor     Descripci¿n
   ------ ---------- --------- ------------------------------------------------
   1.0    16-10-2012 M.R.B     Creaci¿n del package.
   2.0    23-06-2014 S.S.M     Modificaci¿n, se a¿ade parametro  de entrada  pcodgrup
                               a la function f_resuelve_formula

   3.0    18-07-2019 S.P.V.   Tarea IAXIS-4201 Deducibles

/*****************************************************************************

    F_RESUELVE_FORMULA

    Resuelve la f¿rmula que recibe.

    param in      : P_ACCION  Codi de l'acci¿ que estem fent:
                              1 = Nova Producci¿
                              2 = Suplement
                              3 = Renovaci¿
                              4 = Cotizaci¿n
                              5 = Siniestros
    param in      : P_SSEGURO  N¿mero identificativo interno de SEGUROS
    param in      : P_FEFECTO  Fecha para validar la versi¿n de Franquicias
    param in      : P_NRIESGO  Riesgo que estamos tratando
    param in      : P_CFORMULA Clave de SGT_FORMULAS que estamos ejecutando
    param in      : P_NMOVIMI  N¿mero de moviento en el que estamos
    param in out  : Resultado de la ejecuci¿n de la f¿rmula
    param in      : pcodgrup  clave grupo tabla bf_bonfranseg
    Devuelve      : 0 => Correcto ¿ 1 => Error.


   *****************************************************************************/
   FUNCTION f_resuelve_formula(
      p_accion IN NUMBER,
      p_sseguro IN NUMBER,
      p_cactivi IN NUMBER,
      psproduc IN NUMBER,
      pcodgrup IN NUMBER,
      p_fefecto IN DATE,
      p_nriesgo IN NUMBER,
      p_cformula IN NUMBER,
      p_nmovimi IN NUMBER,
      p_resultat OUT NUMBER)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      xxsesion       NUMBER;
      vorigen        NUMBER;   --Bug 26638/161264 - 08/04/2014 - AMC
      vaccion        NUMBER;   --Bug 26638/161264 - 08/04/2014 - AMC
      v_fechatarifa  DATE;
   --
   BEGIN
      --
      -- Asigno una sesi¿n para cada f¿rmula para poder grabar el par¿metro BONFRAN
      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      -- Creamos el par¿metro con el la f¿rmula que estamos tratando.
      v_error := pac_calculo_formulas.graba_param(xxsesion, 'BONFRAN', p_cformula);

      --
      IF v_error != 0 THEN
         p_tab_error
               (f_sysdate, f_user, 'PAC_BONFRAN', NULL,
                'PAC_BONFRAN.F_RESUELVE_FORMULAS DESPUES PAC_CALCULO_FORMULAS.GRABAPARAM '
                || ' Sesi¿ = ' || xxsesion || ' Pcformula = ' || p_cformula || ' Error = '
                || v_error,
                'Codi Error = ' || SQLERRM);
         RETURN v_error;
      END IF;

      xxsesion := NULL;

      -- Ejecuto la f¿rmula i recojo el resultado en p_resultat

      -- Bug 26638/161264 - 08/04/2014 - AMC
      -- Se aprovecha el parametro p_accion que no se utiliza para pasar el origen
      IF p_accion = 3 THEN
         vorigen := 2;
         vaccion := p_accion;
      ELSE
         vorigen := 1;
         vaccion := 1;
      END IF;

      --Deducibles 03/06/2014
      -- Se cambia  a la llamada del  package  pac_calculo_formulas.calc_formul el valor de la fecha
      --se calcula la fecha de la tarifa para que controle y trabaje con las nuevas versiones de datos que
      --se cargan en la tabla SGT_SUBTABS_DET
      BEGIN
         SELECT MIN(ftarifa)
           INTO v_fechatarifa
           FROM estgaranseg
          WHERE sseguro = p_sseguro
            AND cobliga = 1
            AND cgarant IN(SELECT cgarant
                             FROM bf_progarangrup
                            WHERE sproduc = psproduc
                              AND codgrup = pcodgrup);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_BONFRAN', NULL,
                        'PAC_BONFRAN.F_RESUELVE_FORMULAS NO ENCONTRO GRUPO PRODUCTO '
                        || ' Sesi¿ = ' || xxsesion || ' Pcformula = ' || p_cformula
                        || ' Error = ' || v_error,
                        'Codi Error = ' || SQLERRM);
      END;

      v_error := pac_calculo_formulas.calc_formul(p_fefecto, psproduc, p_cactivi, NULL,
                                                  p_nriesgo, p_sseguro, p_cformula, p_resultat,
                                                  p_nmovimi, xxsesion, NVL(vorigen, 1),
                                                  v_fechatarifa /*p_fefecto*/, 'R', NULL,
                                                  vaccion);

      IF v_error != 0 THEN
         p_tab_error
               (f_sysdate, f_user, 'PAC_BONFRAN', NULL,
                'PAC_BONFRAN.F_RESUELVE_FORMULAS DESPUES PAC_CALCULO_FORMULAS.CALC_FORMUL'
                || p_cformula || ' * ' || v_error,
                '** Codi Error = ' || SQLERRM);
         RETURN v_error;
      END IF;

      --
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_BONFRAN', NULL,
                     'PAC_BONFRAN.F_RESUELVE_FORMULAS ERROR ' || p_cformula || ' * '
                     || v_error,
                     '** Codi Error = ' || SQLERRM);
         RETURN 1;
   --
   END f_resuelve_formula;

--------------------------------------------------------------------------
/* Torna el percentatje que implica el GRUP/SUBGRUP/VERSI¿/NIVELL */
   FUNCTION f_porcen_bonus(
      p_cgrup IN NUMBER,
      p_csubgrup IN NUMBER,
      p_cversion IN NUMBER,
      p_cnivel IN NUMBER)
      RETURN NUMBER IS
      --
      v_porcen       NUMBER;
   --
   BEGIN
      SELECT impvalor1
        INTO v_porcen
        FROM bf_detnivel
       WHERE cgrup = p_cgrup
         AND csubgrup = p_csubgrup
         AND cversion = p_cversion
         AND cnivel = p_cnivel;

      --
      RETURN v_porcen;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_BONFRAN', NULL,
                     'PAC_BONFRAN.F_PORCEN_BONUS ERROR ' || ' p_cgrup = ' || p_cgrup || ' * '
                     || ' p_csubgrup = ' || p_csubgrup || ' * ' || ' p_cversion = '
                     || p_cversion || ' * ' || ' p_cnivel = ' || p_cnivel,
                     '** Codi Error = ' || SQLERRM);
         RETURN NULL;
   --
   END f_porcen_bonus;
----------------------------------------------------------------------------
   FUNCTION f_set_deducible(
      pcgrup IN NUMBER,
      pcsubgrup IN NUMBER,
      pcversion IN NUMBER,
      pcnivel IN NUMBER,
      pcvalor1 IN NUMBER,
      pimpvalor1 IN NUMBER,
      pcimpmin IN NUMBER,
      pimpmin IN NUMBER,
      pcimpmax IN NUMBER,
      pimpmax IN NUMBER)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      vcempres NUMBER;
      vcnivel NUMBER;
      vtnivel VARCHAR2(1000);
      vcount NUMBER;
   BEGIN
      vcempres := pac_md_common.f_get_cxtempresa;
      --INI SPV IAXIS-4201 Deducibles
	  
	  /*SELECT COUNT(1)
        INTO vcount
        FROM bf_detnivel
       WHERE cempres = vcempres
         AND cgrup = pcgrup
         AND csubgrup = pcsubgrup
         AND cversion = pcversion
         AND cnivel = pcnivel;*/
      --FIN SPV IAXIS-4201 Deducibles
      vtnivel := pimpvalor1;
        IF pcvalor1 = 1 THEN
          vtnivel := vtnivel || '%';
        END IF;
      --vtnivel := vtnivel || ' '|| f_axis_literales(9909804, pac_md_common.f_get_cxtidioma()) || ' ' || pimpmin;
      IF pcimpmin = 4 THEN
        vtnivel := vtnivel || ' '|| ff_desvalorfijo(1104, pac_md_common.f_get_cxtidioma(), 4);
      END IF;
      -- INI SPV IAXIS-4201 Deducibles
      -- Se coloca el deducible que este por defecto en S a N
       UPDATE BF_DETNIVEL
           SET cdefecto = 'N'
         WHERE cempres  = vcempres
           AND cgrup = pcgrup
           AND csubgrup = pcsubgrup
           AND cversion = pcversion
           AND cdefecto = 'S';
      -- FIN SPV IAXIS-4201 Deducibles
      -- INI SPV IAXIS-4201 Deducibles
	  --IF vcount = 0 THEN
		-- Validamos si existe en desnivel tambien
		SELECT COUNT(*)
		  INTO vcount
		 FROM  bf_desnivel
		 WHERE cgrup = pcgrup
		  AND  csubgrup = pcsubgrup
		  AND  cversion = pcversion
		  AND  tnivel = vtnivel;
		--
		p_control_error('SPV','pac_bonfran','vcount '||vcount);
        IF  vcount = 0 THEN	
           --
         SELECT NVL(max(CNIVEL),0)+1
          INTO vcnivel
          FROM BF_DETNIVEL
         WHERE cempres  = vcempres
           AND cgrup = pcgrup
           AND csubgrup = pcsubgrup;
			--   
			-- Colocamos valor default el deducible ingresado manualmente para comoidad del usuario
			INSERT INTO BF_DETNIVEL (CEMPRES,CGRUP,CSUBGRUP,CVERSION,CNIVEL,NORDEN,CDTOREC,FORMULASELECC,FORMULAVALIDA,FORMULASINIES,CTIPNIVEL,CVALOR1,IMPVALOR1,CVALOR2,IMPVALOR2,CIMPMIN,IMPMIN,CIMPMAX,IMPMAX,CDEFECTO,CCONTRATABLE,CINTERVIENE,CPOLITICA)
				 VALUES (vcempres,pcgrup,pcsubgrup,'1',vcnivel,vcnivel,'2',null,null,null,'2',pcvalor1,pimpvalor1,null,null,nvl(pcimpmin,2),nvl(pimpmin,100000),pcimpmax,pimpmax,'S','S',null,null);
			--
			INSERT INTO BF_DESNIVEL (CEMPRES, CGRUP, CSUBGRUP, CVERSION, CNIVEL, CIDIOMA, TNIVEL, CUSUALT, FALTA) VALUES (vcempres, pcgrup, pcsubgrup, 1, vcnivel, pac_md_common.f_get_cxtidioma , vtnivel, f_user, f_sysdate);
			-- 
        ELSE
		  --
          SELECT DISTINCT cnivel
		    INTO vcnivel
           FROM bf_desnivel
           WHERE cgrup = pcgrup
		     AND  csubgrup = pcsubgrup
		     AND  cversion = pcversion
		     AND  tnivel = vtnivel;		  
		  --  
          UPDATE BF_DETNIVEL
           SET impvalor1 = pimpvalor1,
               cimpmin = nvl(pcimpmin,2),
               impmin = nvl(pimpmin,100000),
               cdefecto = 'S'
         WHERE cempres  = vcempres
           AND cgrup = pcgrup
           AND csubgrup = pcsubgrup
           AND cversion = pcversion
           AND cnivel = vcnivel;
          --		   
		END IF;
		--
      --END IF;
       -- Para actualizar datos de los deducibles poliza 
	   IF vcnivel IS NULL THEN
	     SELECT NVL(max(CNIVEL),0)+1
          INTO vcnivel
          FROM BF_DETNIVEL
         WHERE cempres  = vcempres
           AND cgrup = pcgrup
           AND csubgrup = pcsubgrup;
          --
	    END IF;
		--
		UPDATE estbf_bonfranseg
           SET cnivel = vcnivel,
               impvalor1 = pimpvalor1
          WHERE cgrup = pcgrup;
	   --
	   COMMIT;
       -- FIN SPV IAXIS-4201 Deducible
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_BONFRAN', NULL,
                     'PAC_BONFRAN.f_set_deducible ERROR '
                     || v_error,
                     '** Codi Error = ' || SQLERRM);
         RETURN 1;
   --
   END f_set_deducible;
   FUNCTION f_validar_deducible_manual(
      pcgrup IN NUMBER,
      pcsubgrup IN NUMBER,
      pcversion IN NUMBER,
      pcnivel IN NUMBER,
      pcvalor1 OUT NUMBER,
      pimpvalor1 OUT NUMBER,
      pcimpmin OUT NUMBER,
      pimpmin OUT NUMBER,
      pcimpmax OUT NUMBER,
      pimpmax OUT NUMBER)
      RETURN NUMBER IS
      v_error        NUMBER := 0;
      vcempres NUMBER;
      vcnivel NUMBER;
      vcount NUMBER;
   BEGIN
      vcempres := pac_md_common.f_get_cxtempresa;

      SELECT COUNT(1)
        INTO vcount
        FROM bf_detnivel
       WHERE cempres = vcempres
         AND cgrup = pcgrup
         AND csubgrup = pcsubgrup
         AND cversion = pcversion
         AND ctipnivel = 2;
      IF vcount > 0 THEN
        SELECT cvalor1, impvalor1,cimpmin, impmin, cimpmax, impmax, cnivel
          INTO pcvalor1, pimpvalor1,pcimpmin, pimpmin, pcimpmax, pimpmax, vcnivel
          FROM bf_detnivel
         WHERE cempres = vcempres
           AND cgrup = pcgrup
           AND csubgrup = pcsubgrup
           AND cversion = pcversion
           AND ctipnivel = 2
           AND rownum = 1;
        IF pcnivel IS NOT NULL AND  pcnivel <> vcnivel THEN
          --INI SPV IAXIS-4201 Deducibles
          --RETURN 1;
          NULL;
         --FIN SPV IAXIS-4201 Deducibles
        END IF;
      END IF;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_BONFRAN', NULL,
                     'PAC_BONFRAN.f_validar_deducible_manual ERROR '
                     || v_error,
                     '** Codi Error = ' || SQLERRM);
         RETURN 1;
   --
   END f_validar_deducible_manual;

END pac_bonfran;
/