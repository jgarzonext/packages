CREATE OR REPLACE FUNCTION f_movrecibo(
   pnrecibo IN NUMBER,
   pcestrec IN NUMBER,
   pfvalmov IN DATE,
   pcmovimi IN NUMBER,
   psmovagr IN OUT NUMBER,
   pnliqmen IN OUT NUMBER,
   pnliqlin IN OUT NUMBER,
   pfmovini IN DATE,
   pccobban IN NUMBER,
   pcdelega IN NUMBER,
   pcmotmov IN NUMBER,
   pcagente IN NUMBER,
   pcagrpro IN NUMBER DEFAULT NULL,
   pccompani IN NUMBER DEFAULT NULL,
   pcempres IN NUMBER DEFAULT NULL,
   pctipemp IN NUMBER DEFAULT NULL,
   psseguro IN NUMBER DEFAULT NULL,
   pctiprec IN NUMBER DEFAULT NULL,
   pcbancar IN VARCHAR2 DEFAULT NULL,
   pnmovimi IN NUMBER DEFAULT NULL,
   pcramo IN NUMBER DEFAULT NULL,
   pcmodali IN NUMBER DEFAULT NULL,
   pctipseg IN NUMBER DEFAULT NULL,
   pccolect IN NUMBER DEFAULT NULL,
   pnomovrec IN NUMBER DEFAULT NULL,
   pusu_cob IN NUMBER DEFAULT NULL,
   pfefecrec IN DATE DEFAULT NULL,
   ppgasint IN NUMBER DEFAULT NULL,
   ppgasext IN NUMBER DEFAULT NULL,
   pcfeccob IN NUMBER DEFAULT NULL,
   pctipcob IN NUMBER DEFAULT NULL,
   
   pnreccaj IN VARCHAR2 DEFAULT NULL, -- INI -IAXIS-4153 - JLTS - 05/06/2019 nuevo parámetro-----Changes for 4753
   pcmreca  IN NUMBER DEFAULT NULL,---,-- INI -IAXIS-4153 - JLTS - 05/06/2019 nuevo parámetro
    V_CINDICAF1 IN VARCHAR2 DEFAULT NULL,-----changes for 4944
   V_CSUCURSAL1 IN VARCHAR2 DEFAULT NULL,-----changes for 4944
   V_NDOCSAP1 IN VARCHAR2 DEFAULT NULL,-----changes for 4944
   pcususap IN VARCHAR2 DEFAULT NULL ------Changes for 4944
   ) 
   RETURN NUMBER IS
/*
   F_MOVRECIBO: Añadir registros a la tabla MOVRECIBO.
   - Sección correspondiente al módulo de recibos
   Valida que el cambio de situación del recibo sea uno de los posibles (permitidos).
   Es crida a la funció f_movcta, per a inserir un registre a CTASEGURO, quan es fa
   un cobrament, i anul.lar-lo quan es faci un descobrament.
     També s'ha integrat una crida a la funció f_liquidalin, quan es tracti
     d'un cobrament o descobrament.
   S'afegeixen els paràmetres pfvalmov i pcmovimi,
     per quan haguem de cridar a la funció f_movcta.
   Afegeixo un paràmetre de sortida (pnliqmen), per
     saber el número de liquidació, si aquesta es produeix.
   Implementacion COASEGURO. Se añade una funcion
     que insertará los registros en CTACOASEGURO.
   Se truncan las fechas de movimientos en la comparación
   Se corrije el cmovimi que se graba en las pólizas de ahorro
   Se añaden dos parámetros (motivo de movimiento y agente)
   S'afegeix una crida a la funció f_movcta_ulk en cas que el
     producte tingui el camp cagrpro = 21 (Unit Linked).
   Se incorpora la llamada a la función f_liquidalincia.
   S'elimina la funció f_liquidalincia.
   Canvis al CTIPCAR quan es grava a CARTAAVIS per ALN
   L'Emissió del rebuts genera moviment de liquidació als Agents
         Comercials i Indirectes (no cobradors), però ho farà des del F_VDETRECIBOS
         dons quan es emissió i arriba aquí encara no hi ha les dades d'imports de
         DETRECIBOS necessaris pel F_LIQUIDALIN.
         L'anul·lació del rebut ha de fer el moviment negatiu a la liquidació (XDESEMI).
         La des-anul·lació d'aquests rebuts ha de tornar a fer el moviment positiu a
         liquidació (XANUCOB).
         Resumin fan moviment positiu a liquidació l'emissió del rebut i la desanulació i
         negatiu l'anulació (cobrament i descobrament no generan moviments de liquidació).
         Per que l'aplicació realitzi aquesta funcionalitat s'ha afegit un nou paràmetre
         de PARINTALACION: F_PARINSTALACION_N('EMISIONCOM')=1
         Funcions implicades:
         F_LIQUIDA_EMISION (NOVA)
         F_LIQUIDALIN      (MODIFICADA)
         F_VDETRECIBOS     (MODIFICADA)
         F_MOVRECIBO       (MODIFICADA)
   S'unifiquen els dos accessos a recibos en un.
     Id. accés a seguros
   S'afegeixen els paràmetres : , per defecte null, i es farà la select
     si el valor no ve informat. Caldrà revisar TOTES les crides de f_movrecibo
     per optimitzar.
   Els cobraments de rebuts emesos "G" realitzats per usuaris s'els hi
         modifica el cobrador original pel codi de cobrador del usuari que el fa,
         (pusu_cob = 1 quan el cobrament la fet l'usuari (oficina) i no el cobrador)
   S'afegeixen paràmetres a f_movcta, i f_movrecibo per rendiment
   S'afegeix el parametre NOLIQUI per no cridar a la funció f_liquidaprev
   Se añade el campo CTIPCOB en MOVRECIBO. Se modifica la función añadiendo
         un parámetro para pasar el valor de este campo nuevo.
  Se añade el parametro HAYCTACLIENTE y si = 1 accede al package ctacliente
*/ /******************************************************************************
   NOMBRE:       F_MOVRECIBO
   PROPÓSITO:    Genera un movimiento del recibo

   REVISIONES:
   Ver        Fecha     Autor     Descripción
   ------- ----------  -------   ------------------------------------
   1.0     XX/XX/XXXX  XXX       Creació de la funció
   2.0     27/10/2011  JGR       0019793: LCOL_A001-Formato de cuentas bancarias y tarjetas de credito
   3.0     26/10/2011  JMP       0018423: LCOL000 - Multimoneda
   4.0     25/11/2011  JGR       0020037: Parametrización de Devoluciones
   5.0     20/12/2011  JMP       0018423: LCOL000 - Multimoneda:
                                          Se eliminan llamadas a PAC_OPER_MONEDAS.F_CONTRAVALOR_CTASEGURO, ya que este cálculo
                                          se realizará cada vez que se inserte o actualice una línea en CTASEGURO.
   6.0     14/08/2012  DCG       0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   7.0     25/09/2014  RDD       0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
   8.0     02/12/2014  RDD       0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
   9.0     07/06/2019  JLTS      IAXIS-4153: Se incluyen nuevos parámetros pnreccaj y pcmreca
   10.0    17/07/2019  SHAKTI      IAXIS-4753: Ajuste campos Servicio I003
   11.0    19/09/2019  DFRP      IAXIS-5327: Ajuste en la tabla MOVRECIBO
   ******************************************************************************/
   xsseguro       NUMBER;
   xfmovini       DATE;
   xsmovrec       NUMBER;
   xsmovagr       NUMBER;
   error          NUMBER := 0;
   anterior       NUMBER := 1;
   xcestrec       NUMBER;
   xcestant       NUMBER;
   xcagente       NUMBER;
   xcempres       NUMBER;
   xmovant        NUMBER;
   xcramo         NUMBER;
   xcmodali       NUMBER;
   xctipseg       NUMBER;
   xccolect       NUMBER;
   xcobram        BOOLEAN := FALSE;
   xdescob        BOOLEAN := FALSE;
   xemianu        BOOLEAN := FALSE;
   --> Anul·lació quan hi ha mov.liquis x emissió
   xemipen        BOOLEAN := FALSE;
   --> Desanul·lació quan hi ha mov.liquis x emissió
   xnmovimi       NUMBER;
   xcmovimi       NUMBER;
   xfvalmov       DATE;
   xfmovimi       DATE;
   xahorro        NUMBER;
   xcmotmov       NUMBER;
   xrowid         ROWID;   -- optimizacion del tiempo
   xctiprec       NUMBER;
   xcagrpro       NUMBER := 0;
   xccobban       NUMBER;
   xcbancar       recibos.cbancar%TYPE;
-- 27/10/2011 JGR 19793: LCOL_A001-Formato de cuentas bancarias y tarjetas de credito
   xccompani      NUMBER;
   xctipemp       NUMBER;
   xnada          VARCHAR2(1);
   xemisioncom    NUMBER(2) := NVL(f_parinstalacion_n('EMISIONCOM'), 0);
   --> 1 = Comissió a l'emissió
   x1ercobro      NUMBER := 0;
--> 1er cobrament d'un rebut(x1ercobro=1) no ha de fer apunt quan xemisioncom=1
   xcliente       VARCHAR2(100) := f_parinstalacion_t('CLIENTE');
   --JRH tarea 6966
   xfestimp       DATE;
   xcagecob       NUMBER;
   xliquida       NUMBER := 1;
   lcapital       NUMBER;
   esta_retenida  NUMBER;
   num_err        NUMBER;
   vnmovimi       NUMBER;
   xanula         BOOLEAN;
   v_sproduc      NUMBER;
   lnomesextra    NUMBER;
   vforpag        NUMBER;
   vpasexec       NUMBER := 0;
   xcestaux       recibos.cestaux%TYPE;
   v_seqcaja      NUMBER;
   v_importe      NUMBER := 0;
   V_CINDICAF VARCHAR2(100);
   V_CSUCURSAL VARCHAR2(1000);
   V_NDOCSAP VARCHAR2(150);
   V_NLINEA NUMBER(5);
   V_CUSUPAG	VARCHAR2(150);
   --
   -- Cursor de obtencion del agente cobrador del usuario
   --
   CURSOR cur_usucob IS
      SELECT cagecob
        FROM usuarios
       WHERE cusuari = f_user
         AND cagecob IS NOT NULL;

   verror         NUMBER;
   vterminal      VARCHAR2(20);
   perror         VARCHAR2(2000);

   CURSOR rtn_rec(pc_nrecibo IN NUMBER) IS
      SELECT   nrecibo, nrecretorno
          FROM rtn_recretorno
         WHERE nrecibo = pc_nrecibo
      ORDER BY nrecretorno;

   CURSOR c_clawback(pc_nrecibo NUMBER) IS
      SELECT DISTINCT nrecibo_des
                 FROM movclawback
                WHERE nrecibo = pc_nrecibo;

   v_contador     NUMBER := 0;
   v_dummy22      NUMBER := 0;
BEGIN
   -- Mirem si es vol gravar a liquidacions = 1/null(grava) , 0(No grava)
   xliquida := NVL(f_parinstalacion_n('LIQUIDA'), 1);
   vpasexec := 1;

    -- BUG 14185 - 06/2010 - JRH  -  Se deja versión anterior
   -- Fi BUG 14185 - 06/2010 - JRH
     -- Mirem si el producte es Unit Linked.
     -- Obtenim camps de recibos, seguros, ...
   IF psseguro IS NULL
      OR pcempres IS NULL
      OR pctiprec IS NULL
      OR pccobban IS NULL
      OR pcbancar IS NULL
      OR pcagente IS NULL
      OR pnmovimi IS NULL THEN
      ------ posar condició amb pusucob
      ------
      -----
      SELECT sseguro, cempres, ctiprec, ccobban, cbancar, cagente, nmovimi, festimp,
             cestaux
        INTO xsseguro, xcempres, xctiprec, xccobban, xcbancar, xcagente, xnmovimi, xfestimp,
             xcestaux
        FROM recibos
       WHERE nrecibo = pnrecibo;
   ELSE
      xsseguro := psseguro;
      xcempres := pcempres;
      xctiprec := pctiprec;
      xccobban := pccobban;
      xcbancar := pcbancar;
      xcagente := pcagente;
      xnmovimi := pnmovimi;

      IF pnrecibo IS NOT NULL THEN
         BEGIN
            SELECT cestaux
              INTO xcestaux
              FROM recibos
             WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS THEN
               xcestaux := NULL;
         END;
      END IF;
   END IF;

   vpasexec := 2;

   IF pctipemp IS NULL THEN
      SELECT ctipemp
        INTO xctipemp
        FROM empresas
       WHERE cempres = xcempres;
   ELSE
      xctipemp := pctipemp;
   END IF;

   vpasexec := 3;

   IF (NVL(xctipemp, 0) = 0
       AND(pcramo IS NULL
           OR pcmodali IS NULL
           OR pctipseg IS NULL
           OR pccolect IS NULL
           OR pcagrpro IS NULL))
      OR(NVL(xctipemp, 0) = 1
         AND(pccompani IS NULL
             OR pcramo IS NULL
             OR pcmodali IS NULL
             OR pctipseg IS NULL
             OR pccolect IS NULL
             OR pcagrpro IS NULL)) THEN
      -- Si l'empresa és correduria, necessitem la companyia asseguradora i el producte
      -- si l'empresa és companyia asseguradora, només el producte
      SELECT ccompani, cramo, cmodali, ctipseg, ccolect, cagrpro
        INTO xccompani, xcramo, xcmodali, xctipseg, xccolect, xcagrpro
        FROM seguros
       WHERE sseguro = xsseguro;
   ELSE
      xccompani := pccompani;
      xcramo := pcramo;
      xcmodali := pcmodali;
      xctipseg := pctipseg;
      xccolect := pccolect;
      xcagrpro := pcagrpro;
   END IF;

   vpasexec := 3;
   --JRH 08/2008 IMP
   -- obtenemos el sproduc del ramo, etc
   error := f_sproduc(xcramo, xcmodali, xctipseg, xccolect, v_sproduc);

   IF error <> 0 THEN
      RETURN error;
   END IF;

   vpasexec := 4;
   num_err := f_parproductos(v_sproduc, 'NOMESEXTRA', lnomesextra);
   --JRH 08/2008 IMP
   lnomesextra := NVL(lnomesextra, 0);

   SELECT cforpag
     INTO vforpag
     FROM seguros
    WHERE sseguro = xsseguro;

   vpasexec := 5;

   --JRH 08/2008 IMP
   IF (NVL(xctipemp, 0) = 0
       AND xcagrpro IS NULL)
      OR(NVL(xctipemp, 0) = 1
         AND(xcagrpro IS NULL
             OR xccompani IS NULL)) THEN
      SELECT cagrpro, ccompani
        INTO xcagrpro, xccompani
        FROM productos
       WHERE cramo = xcramo
         AND cmodali = xcmodali
         AND ctipseg = xctipseg
         AND ccolect = xccolect;
   END IF;

   vpasexec := 6;

   -- Mirem si existeixen moviments anteriors
   BEGIN
      SELECT ROWID, fmovini, cestrec, cestant, smovagr, smovrec
        INTO xrowid, xfmovini, xcestrec, xcestant, xmovant, xsmovrec
        FROM movrecibo
       WHERE nrecibo = pnrecibo
         AND fmovfin IS NULL;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         anterior := 0;
      WHEN OTHERS THEN
         RETURN 104043;   -- Error al llegir de MOVRECIBO
   END;

   vpasexec := 7;

   --Se ponen los TRUNCs
   --  IF xfmovini > pfmovini THEN
   IF TRUNC(xfmovini) > TRUNC(pfmovini) THEN
      RETURN 100531;   -- No se puede crear un movimiento anterior
   ELSE
      IF xcestrec > 3 THEN   -- tratamiento asesoría jurídica
         RETURN 101915;   -- Valor incorrecto del estado del recibo
      ELSE
          IF pcestrec = 0 THEN -- 16/06/2016 POSINS-108 inicio
            IF xctiprec = 10 THEN
               xdescob := FALSE;
               RETURN 9001656;
                     -- No es un descobrament (el rebut només estava remesat)
            ELSIF xcestrec = 0 THEN
               RETURN 101909; -- El recibo está pendiente
            ELSIF xcestrec = 1 THEN
               xdescob := TRUE; -- Es un descobrament
            -- alberto, si es traspaso de entrada no se puede devolver
            ELSIF xcestrec = 3 THEN
               -- 4.0 25/11/2011 JGR 20037: Parametrización de Devoluciones - Inici
               -- RETURN 101909; --JRH No dejamos -- Ve d'assessoria jurídica
               xdescob := FALSE;
            -- 4.0 25/11/2011 JGR 20037: Parametrización de Devoluciones - Fi
            END IF; -- 16/06/2016 POSINS-108 fin
         ELSIF pcestrec = 1 THEN
            IF xcestrec IN(0, 3) THEN   --JRH Nuevo Estado
               xcobram := TRUE;   -- Es un cobrament
            ELSIF xcestrec IN(1) THEN
               IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                    'PAGAR_REB_PAGADOS'),
                      0) = 0 THEN
                  RETURN 101126;   -- El recibo no está pendiente de cobro
               ELSIF xcestrec = 1 THEN
                  RETURN 0;
               END IF;
            ELSIF xcestrec = 2 THEN
               RETURN 101910;   -- El recibo está anulado
            END IF;
         ELSIF pcestrec = 2 THEN
            IF xcestrec = 2 THEN
               RETURN 101910;   -- El recibo está anulado
            ELSIF xcestrec = 1 THEN
               RETURN 101911;   -- El recibo está cobrado.
--            ELSIF xcestrec = 3 THEN
--               IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
--                                                    'PAGAR_REB_PAGADOS'),
--                      0) = 0 THEN
--                  RETURN 101126;   -- El recibo no está pendiente
--               ELSIF xcestrec = 1 THEN
--                  RETURN 0;
--               END IF; --JRH El 3 se deja anular
            ELSE
               xanula := TRUE;
            END IF;
         ELSIF pcestrec = 3 THEN
            IF xcestrec = 0 THEN   --JRH Nuevo Estado
               NULL;   -- Es un cobrament
            ELSIF xcestrec = 3 THEN
               RETURN 101909;   -- El recibo está pendiente
            ELSIF xcestrec IN(1) THEN
               RETURN 101911;   -- El recibo está cobrado.
            ELSIF xcestrec = 2 THEN
               RETURN 101910;   -- El recibo está anulado
            END IF;
         END IF;
      END IF;
   ---
   ---
   END IF;

   vpasexec := 8;

   IF xcobram THEN
-------------------------------------------------
      IF pusu_cob IS NOT NULL
         AND   --> Cobrament fet pel usuari
            anterior = 0
         AND
            --> No te moviments anteriors
            xfestimp IS NULL THEN   --> Es de cobrament manual
--> Rebuts (ALN "G") emesos i tant de cobrament manual con bancari
--> i l'acció no correspont al cobrament d'un agent cobrador s'ha
--> de modificar l'agent cobrador pel codi cobrador del usuari.
------------------------------------------------------------------
--> Cambiar el agente cobrador por el del usuario
--> trigger de B.B.D.D. genera copia en HISAGECOB
         OPEN cur_usucob;

         FETCH cur_usucob
          INTO xcagecob;

         IF cur_usucob%FOUND THEN
            UPDATE agentescob
               SET cagecob = xcagecob
             WHERE nrecibo = pnrecibo
               AND cagecob != xcagecob;
         END IF;

         CLOSE cur_usucob;
      END IF;

      vpasexec := 9;

      IF xemisioncom = 1 THEN
         -- Mirem si es el 1er moviment de cobrament (no ha de donar comissió)
         BEGIN
            SELECT DISTINCT 0
                       INTO x1ercobro
                       FROM movrecibo m
                      WHERE m.nrecibo = pnrecibo
                        AND m.cestrec = 1
                        AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               x1ercobro := 1;   --> Es el primer cobrament
            WHEN OTHERS THEN
               RETURN 104043;   -- Error al llegir de MOVRECIBO
         END;
      END IF;
   END IF;

   vpasexec := 10;

   BEGIN
      SELECT smovrec.NEXTVAL
        INTO xsmovrec
        FROM DUAL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 104060;   -- Error al llegir la seqüència (smovrec) de BD
   END;

   vpasexec := 11;

   IF psmovagr = 0 THEN
      BEGIN
         SELECT smovagr.NEXTVAL
           INTO xsmovagr
           FROM DUAL;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104061;   -- Error al llegir la seqüència (smovagr) de BD
      END;

      psmovagr := xsmovagr;
   ELSE
      xsmovagr := psmovagr;
   END IF;

   vpasexec := 12;

   -- xcempres obtingut a la query de recibos, seguros ,...
   -- error       := f_empresa(NULL, pnrecibo, NULL, xcempres);
   IF error = 0 THEN
      IF anterior = 1
         AND   --> Hay un movimiento anterior
            pnomovrec IS NULL THEN   --> No se ha modificar la tabla MOVRECIBO
         BEGIN
            UPDATE movrecibo
               SET fmovfin = TO_DATE(TO_CHAR(pfmovini, 'ddmmyyyy'), 'ddmmyyyy')
             WHERE ROWID = xrowid;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user,
                           'f_movrecibo UPDATE movrecibo SET fmovfin = '
                           || TO_CHAR(pfmovini, 'ddmmyyyy'),
                           vpasexec, 'WHEN OTHERS RETURN 100532', SQLERRM);
               RETURN 100532;   -- Error al modificar la taula MOVRECIBO
         END;
      END IF;

      vpasexec := 13;

      BEGIN
         --        
         -- Inicio IAXIS-5327 19/09/2019   
         --
         BEGIN
           SELECT cmotmov
             INTO xcmotmov
             FROM movseguro
            WHERE sseguro = xsseguro
              AND nmovimi = xnmovimi;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             RETURN 104348;
             -- Número de movimiento no encontrado en la tabla MOVSEGURO
           WHEN OTHERS THEN
             RETURN 104349;
             -- Error al leer de la tabla MOVSEGURO
         END;
         --
         -- Fin IAXIS-5327 19/09/2019     
         --
         IF pnomovrec IS NULL THEN   --> No se ha modificar la tabla MOVRECIBO
	   -- INI -IAXIS-4153 - JLTS - 05/06/2019
            INSERT INTO movrecibo
                        (smovrec, cestrec, fmovini, fcontab, fmovfin, nrecibo,
                         cestant, cusuari, smovagr, fmovdia, cmotmov, ccobban,
                         cdelega, ctipcob,nreccaj,cmreca,CINDICAF,CSUCURSAL,NDOCSAP)
                 VALUES (xsmovrec, pcestrec, TRUNC(pfmovini), NULL, NULL, pnrecibo,
                         NVL(xcestrec, 0), NVL(pcususap, f_user), xsmovagr, f_sysdate, NVL(pcmotmov, xcmotmov), pccobban, -- IAXIS-5327 19/09/2019 
                         pcdelega, pctipcob,pnreccaj,pcmreca,V_CINDICAF1,V_CSUCURSAL1,V_NDOCSAP1);
	   -- INI -IAXIS-4153 - JLTS - 05/06/2019
       -----pcususap,V_CINDICAF1,V_CSUCURSAL1,V_NDOCSAP1 changes for 4944
         END IF;

         vpasexec := 14;

         -- Si el recibo está pendiente de imprimir o pendiente de domiciliar se pone a
         -- no imprimible para las anulaciones.
         UPDATE recibos
            SET cestimp = DECODE(pcestrec, 2, DECODE(cestimp, 1, 0, 4, 0, cestimp), cestimp)
          WHERE nrecibo = pnrecibo;

-- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
--         IF xcobram
--            OR xdescob THEN
--            -- Se trata de un cobro o una anulacion de cobro
--            error := f_insctacoas(pnrecibo, pcestrec, xcempres, xsmovrec, TRUNC(pfmovini));

         --            IF error != 0 THEN
--               RETURN error;
--            END IF;
--         END IF;
         IF pcestrec = 2 THEN
            -- Se trata de una anulacion de cobro
            error := f_insctacoas(pnrecibo, pcestrec, xcempres, xsmovrec, TRUNC(pfmovini));

            IF error != 0 THEN
               RETURN error;
            END IF;

            --JRB AÑADIMOS QUE ANULE TAMBIÉN LOS RECIBOS DE RETORNO
            FOR r_rtn IN rtn_rec(pnrecibo) LOOP
               vpasexec := 14001;
               error := f_movrecibo(r_rtn.nrecretorno, 2, pfvalmov, 2, psmovagr, pnliqmen,
                                    pnliqlin, pfmovini, pccobban, pcdelega, pcmotmov,
                                    pcagente);

               IF num_err != 0 THEN
                  RETURN error;
               END IF;
            END LOOP;
         END IF;
-- Fin Bug 0023183
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            p_tab_error(f_sysdate, f_user, 'f_movrecibo ' || TO_CHAR(pfmovini, 'ddmmyyyy'),
                        vpasexec, 'WHEN DUP_VAL_ON_INDEX THEN RETURN 104062', SQLERRM);
            RETURN 104062;   -- Registre duplicat a MOVRECIBO
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'f_movrecibo ' || TO_CHAR(pfmovini, 'ddmmyyyy'),
                        vpasexec, 'WHEN OTHERS THEN RETURN 100533', SQLERRM);
            RETURN 100533;   -- Error a l' inserir a MOVRECIBO
      END;

      vpasexec := 15;

      IF xcobram
         OR xdescob THEN
         xcmovimi := pcmovimi;
         xfvalmov := pfvalmov;

         IF xcmovimi IS NULL THEN
            xahorro := f_esahorro(pnrecibo, NULL, error);

            IF error = 0 THEN
               IF xahorro = 1 THEN   -- Es d' estalvi
                  BEGIN
                     SELECT cmotmov, fmovimi
                       INTO xcmotmov, xfmovimi
                       FROM movseguro
                      WHERE sseguro = xsseguro
                        AND nmovimi = xnmovimi;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        RETURN 104348;
                     -- Número de moviment no trobat a MOVSEGURO
                     WHEN OTHERS THEN
                        RETURN 104349;   -- Error al llegir de MOVSEGURO
                  END;

                  vpasexec := 16;

                  IF xcmotmov = 500
                     AND xctiprec <> 3 THEN
                     --Si no es de cartera
                     xcmovimi := 1;   -- Aportació extraordinària
                     xfvalmov := xfmovimi;

                     --JRH 12/2008
                     --Dependiendo de que garantía tiene la aportación extraordinaria ponemos un movimiento
                     --de cuentaseguro u otro.
                     --Sólo una cobertura por recibo!!!!
                     BEGIN
                        SELECT DECODE(detrecibos.cgarant,
                                      56, 85,
                                      57, 84,
                                      58, 88,
                                      1)   --Por defecto el 1 como siempre
                          INTO xcmovimi
                          FROM seguros, recibos, detrecibos
                         WHERE detrecibos.nrecibo = pnrecibo
                           AND detrecibos.cconcep = 0
                           AND recibos.nrecibo = detrecibos.nrecibo
                           AND seguros.sseguro = recibos.sseguro
                           AND f_pargaranpro_v(seguros.cramo, seguros.cmodali, seguros.ctipseg,
                                               seguros.ccolect, seguros.cactivi,
                                               detrecibos.cgarant, 'TIPO') IN(4, 12);   --JRH Este 12 ?
                     EXCEPTION
                        WHEN OTHERS THEN
                           -- BUG8757:DRA:23-01-2009
                           -- Si falla, que haga lo mismo que antes
                           xcmovimi := 1;
                     END;
                  ELSIF xcmotmov = 100
                        AND xctiprec NOT IN(3, 10) THEN   --JGM : Cpina actualiza para traspasos para tipo 10
                     vpasexec := 17;

                     IF lnomesextra = 0
                        AND vforpag <> 0 THEN   --JRH 01/2008 Cambiado todo lo de dentro
                        BEGIN
                           SELECT icapital
                             INTO lcapital
                             FROM garanseg
                            WHERE sseguro = xsseguro
                              -- AND cgarant = 282
                              AND f_pargaranpro_v(xcramo, xcmodali, xctipseg, xccolect, 0,
                                                  cgarant, 'TIPO') = 4
                              AND nmovimi = xnmovimi;

                           IF xctiprec = 0 THEN
                              xcmovimi := 2;
                           ELSIF xctiprec = 4 THEN
                              xcmovimi := 1;
                           ELSE
                              xcmovimi := 1;
                           END IF;

                           xfvalmov := xfmovimi;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              xcmovimi := 2;
                              xfvalmov := xfmovimi;
                           WHEN OTHERS THEN
                              RETURN 103500;
                        END;
                     ELSE
                        xcmovimi := 1;
                        xfvalmov := xfmovimi;
                     END IF;
                  ELSIF xctiprec = 10 THEN
-- CPM 2/1/06: Traspaso de entrada --JGM : Cpina actualiza para traspasos para tipo 10
                     xcmovimi := 8;
                     xfvalmov := xfmovimi;
                  ELSE
                     xcmovimi := 2;   -- Renovació
                     xfvalmov := xfmovimi;
                  END IF;
               END IF;
            ELSE
               RETURN error;
            END IF;
         END IF;
      END IF;

      vpasexec := 18;

      -- Miramos si hay que desretener la póliza
      IF xcobram
         OR xanula THEN
         -- Si la póliza está retenida por impago se desretiene
         SELECT COUNT(*)
           INTO esta_retenida
           FROM movseguro
          WHERE cmovseg = 10   -- RETENCION
            AND sseguro = xsseguro
            AND cmotmov = 115
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM movseguro
                            WHERE sseguro = xsseguro);

         IF esta_retenida > 0 THEN   -- si está retenida la desretenemos
            num_err := f_movseguro(xsseguro, NULL, 116, 11, pfmovini, NULL, NULL, 0, NULL,
                                   vnmovimi, f_sysdate);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;

         vpasexec := 19;
      END IF;

      vpasexec := 20;

      --> Aquests controls es fan en aquest punt per aprofitar el control d'errors anteriors,
      --> i si es "EMISIONCOM" tornem a informar el XCOBRAM i XDESCOB amb els valor corresponents.
      IF xcobram THEN
         IF error <> 0 THEN
            RETURN error;
         END IF;

         -- S'ha eliminat la crida a f_liquidalincia
         --Si el Rebut es de Unit Linked
         vpasexec := 21;
         -- obtenemos el sproduc del ramo, etc
         error := f_sproduc(xcramo, xcmodali, xctipseg, xccolect, v_sproduc);

         IF error <> 0 THEN
            RETURN error;
         END IF;

         IF xcmovimi IS NOT NULL
            AND NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
            error := f_movcta_ulk(pnrecibo, xsmovrec, 1, xcmovimi, xfvalmov, pfmovini);

            IF error <> 0 THEN
               RETURN error;
            END IF;
         END IF;

         vpasexec := 22;

         --Si el Rebut es Plans de Pensiones i Rendes
         IF xcmovimi IS NOT NULL
            AND(NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_AHO'), 0) = 1
                --OR xcagrpro IN(11, 10, 2)) THEN
                OR xcagrpro IN(10, 2)) THEN   -- BUG 12440 MRB PPJ CIV 22-12-2009
            error := f_movcta(pnrecibo, xsmovrec, 1, xcmovimi, xfvalmov, pfmovini, f_sysdate,
                              xsseguro, pfefecrec, xctiprec, xcramo, xcmodali, xctipseg,
                              xccolect, ppgasint, ppgasext, pcfeccob);

            IF error <> 0 THEN
               RETURN error;
            END IF;
         END IF;
      ELSIF xdescob THEN   -- Es un descobrament
         vpasexec := 23;
         vpasexec := 24;
         error := f_sproduc(xcramo, xcmodali, xctipseg, xccolect, v_sproduc);

         IF error <> 0 THEN
            RETURN error;
         END IF;

         --Si el Rebut es Plans de Pensiones i Rendes
         --IF  xcmovimi IS NOT NULL AND xcagrpro IN (11, 10, 2) THEN
         -- Comentamos esta linea y la sustituimos
         --IF  xcmovimi IS NOT NULL AND xcagrpro = 21 THEN
         IF xcmovimi IS NOT NULL
            AND((NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1
                 AND NVL(f_parproductos_v(v_sproduc, 'PRODUCTO_MIXTO'), 0) = 1)
                --OR xcagrpro IN(11, 10, 2)) THEN
                OR(xcagrpro IN(10, 2)
                   AND NVL(pac_adm.f_es_recibo_ahorro(pnrecibo), 0) = 1)) THEN   -- BUG 12440 PPJ CIV MRB 22-12-2009
            vpasexec := 25;
            error := f_movcta(pnrecibo, xsmovrec, 2, xcmovimi, xfvalmov, pfmovini, f_sysdate,
                              xsseguro, pfefecrec, xctiprec, xcramo, xcmodali, xctipseg,
                              xccolect, ppgasint, ppgasext, pcfeccob);

            IF error <> 0 THEN
               RETURN error;
            END IF;
         END IF;

         vpasexec := 26;

         -- S'ha eliminat la crida a f_liquidalincia
         -- Si el Rebut es de Unit Linked
         -- Comentamos esta linea y la sustituimos
         --IF  xcmovimi IS NOT NULL AND xcagrpro = 21 THEN
         IF xcmovimi IS NOT NULL
            AND NVL(f_parproductos_v(v_sproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN
            error := f_movcta_ulk(pnrecibo, xsmovrec, 2, xcmovimi, xfvalmov, pfmovini);

            IF error <> 0 THEN
               RETURN error;
            END IF;
         END IF;
      END IF;

      vpasexec := 27;

      -- Càlcul de la Reaseegurança només l'anul.lació del rebut.
      -- INI -IAXIS-13133 -11/05/2020. Se adiciona el pcestrec 3
      IF pcestrec in (2,3) THEN
         error := pac_cesionesrea.f_cesdet_anu(pnrecibo);

         IF error <> 0 THEN
            RETURN error;
         END IF;
      END IF;
      -- FIN -IAXIS-13133 -11/05/2020.

      IF NVL(pac_parametros.f_parempresa_n(xcempres, 'GESTIONA_COBPAG'), 0) = 1
         AND(pcestrec = 2
             OR(pcestrec = 1
                AND NVL(pac_parametros.f_parempresa_n(xcempres, 'CONTAB_ONLINE'), 0) = 1))
         AND xcestaux <> 2
                          --JRH  Anulación lo ponemos separado para que esté más separado de la emisión
      THEN
         DECLARE
            vtipopago      NUMBER;
            vemitido       NUMBER;
            vsinterf       NUMBER;
            vsubfi         VARCHAR2(100);
            ss             VARCHAR2(3000);
            v_cursor       NUMBER;
            v_ttippag      NUMBER := 4;
            v_ttippag_int  NUMBER;
            v_filas        NUMBER;
         BEGIN
            --JRB 25/09/2012 22701 - Se llama a la interficie de CxP cuando el tipo de recibo es 15 en retornos
            vsubfi := pac_parametros.f_parempresa_t(xcempres, 'SUFIJO_EMP');
            ss := 'BEGIN ' || ' :RETORNO := PAC_PROPIO_' || vsubfi || '_INT.'
                  || 'f_obtener_ttippag(' || xctiprec || ')' || ';' || 'END;';

            IF DBMS_SQL.is_open(v_cursor) THEN
               DBMS_SQL.close_cursor(v_cursor);
            END IF;

            BEGIN
               v_cursor := DBMS_SQL.open_cursor;
               DBMS_SQL.parse(v_cursor, ss, DBMS_SQL.native);
               DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_ttippag_int);
               v_filas := DBMS_SQL.EXECUTE(v_cursor);
               DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_ttippag_int);

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  v_ttippag_int := NULL;
            END;

            verror := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);

            /*--INI CONF-403  LR
            verror := pac_con.f_emision_pagorec(xcempres, 1, NVL(v_ttippag_int, v_ttippag),
                                                pnrecibo, xsmovrec, vterminal, vemitido,
                                                vsinterf, perror, f_user);
*/

verror:= pac_ctrl_env_recibos.f_procesar_reccaus(xcempres, NVL(v_ttippag_int, v_ttippag), pnrecibo, xsmovrec,
                                     NULL, NULL, perror, vsinterf,1);
--FIN CONF-403 LR






            IF verror <> 0
               OR TRIM(perror) IS NOT NULL THEN
               IF verror = 0 THEN
                  verror := 151323;
               END IF;

               p_tab_error(f_sysdate, f_user, 'f_movrecibo.f_movpago', 1,
                           'error no controlado', perror || ' ' || verror);
               --Mira si borraar sin_tramita_movpago porque se tiene que hacer un commit para que loo vea el sap
               RETURN verror;
            END IF;
         END;
      END IF;

      -- Fi BUG 17247-  02/2011 - JRH
      vpasexec := 28;

      --------- INI BUG 25951- 03/2013 CTACLIENTE (COBRANZA)
      -- Si es nueva emisión se controla en aquellos fuentes que dan de alta pq aquí no tenemos aún importes cuando
      -- es un recibo de nueva emisión.
      IF NVL(f_parproductos_v(v_sproduc, 'HAYCTACLIENTE'), 0) = 1
         AND xctiprec != 5 THEN
         IF (pcestrec = 0
             AND NVL(xcestrec, 0) = 0)
            -- Bug 0032663 Ini no considerar los recibos agrupados
            OR(pcestrec = 0
               AND NVL(xcestrec, 0) = 1
               AND xcestaux = 2)
                                -- Bug 0032663 Fin
         THEN
            NULL;
         ELSE
            error := pac_ctacliente.f_ins_movrecctacli(xcempres, xsseguro, xnmovimi, pnrecibo);

            IF error <> 0 THEN
               RETURN error;
            END IF;
         END IF;
      ELSIF NVL(f_parproductos_v(v_sproduc, 'HAYCTACLIENTE'), 0) = 2
            AND xctiprec != 5 THEN
         IF (pcestrec = 0
             AND NVL(xcestrec, 0) = 0)
            -- Bug 0032663 Ini no considerar los recibos agrupados
            OR(pcestrec = 0
               AND NVL(xcestrec, 0) = 1
               AND xcestaux = 2)
                                -- Bug 0032663 Fin
         THEN
            IF pcestrec = 1
               AND xctiprec = 9
               AND NVL(pac_parametros.f_parempresa_n(xcempres, 'CAJA_COBRA_RECEXT'), 0) = 1 THEN
               SELECT SUM(NVL(vm.itotalr, v.itotalr))
                 INTO v_importe
                 FROM vdetrecibos v, vdetrecibos_monpol vm
                WHERE v.nrecibo = pnrecibo
                  AND vm.nrecibo(+) = v.nrecibo;
            END IF;

            error := pac_ctacliente.f_apunte_pago_spl(pcempres => xcempres,
                                                      psseguro => xsseguro,
                                                      pimporte => v_importe,
                                                      pseqcaja => v_seqcaja);

            IF error <> 0 THEN
               RETURN error;
            END IF;
         ELSE
            error := pac_ctacliente.f_apunte_spl(xcempres, xsseguro, xnmovimi, pnrecibo);

            IF error <> 0 THEN
               RETURN error;
            END IF;

            IF /*NOT(pcestrec = 0
                   AND NVL(xcestrec, 0) = 1) */
               pcestrec = 2 THEN
               -- Si no es una devolución, que haga el matching
               error := pac_ctacliente.f_apunte_pago_spl(pcempres => xcempres,
                                                         psseguro => xsseguro, pimporte => 0,
                                                         pseqcaja => v_seqcaja);

               IF error <> 0 THEN
                  RETURN error;
               END IF;
            END IF;
         END IF;
      END IF;

      vpasexec := 29;

--------- FIN BUG 25951- 03/2013 CTACLIENTE (COBRANZA)
        /*
        rdd 25/09/2014
        al momento de hacer retrocesión de comisiones especial tenemos que cada recibo de retrocesion está asignado
        a un recibo comun y corriente, si este recibo a cambiado de estado alguna vez a cobrado o anulado se heredara estado
        */
      IF pac_parametros.f_parproducto_n(psproduc => v_sproduc,
                                        pcparam => 'AFECTA_COMISESPPROD') = 1
         AND xctiprec != 5 THEN
         --v_nrecibo_des := NULL;
         FOR i IN c_clawback(pnrecibo) LOOP
            IF f_parproductos_v(v_sproduc, 'RECIBOS_REHABILITA') = 1 THEN
               SELECT COUNT(1)
                 INTO v_contador
                 FROM movrecibo mr
                WHERE mr.nrecibo = pnrecibo
                  AND mr.cestrec = 1;   --FUE ALGUNA VEZ COBRADO

               IF (f_cestrec(i.nrecibo_des, f_sysdate) = 0
                   AND v_contador > 0) THEN
                  --      p_tab_error(f_sysdate, f_user, 'F_MOVRECIBO', vpasexec, 'entrando', 0);
                  error := f_movrecibo(i.nrecibo_des, 1, NULL, NULL, psmovagr, pnliqmen,
                                       pnliqlin, pfmovini, pccobban, NULL, NULL, NULL);
               END IF;
            END IF;

            IF f_parproductos_v(v_sproduc, 'RECIBOS_REHABILITA') = 2 THEN
               IF f_cestrec(pnrecibo, f_sysdate) != f_cestrec(i.nrecibo_des, f_sysdate) THEN
                  error := f_movrecibo(i.nrecibo_des, f_cestrec(pnrecibo, f_sysdate), NULL,
                                       NULL, psmovagr, pnliqmen, pnliqlin, pfmovini, pccobban,
                                       NULL, NULL, NULL);
               END IF;
            END IF;

            IF num_err <> 0 THEN
               RETURN error;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   ELSE
      RETURN error;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      -- BUG 21546_108724 - 09/02/2012 - JLTS - Cierre de posibles cursores abiertos
      IF cur_usucob%ISOPEN THEN
         CLOSE cur_usucob;
      END IF;

      -- BUG8757:DRA:23-01-2009:Que devuelva un error controlado si hay algun incontrolado
      p_tab_error(f_sysdate, f_user, 'F_MOVRECIBO', vpasexec,
                  'pnrecibo: ' || pnrecibo || ' pcestrec: ' || pcestrec || ' pfvalmov: '
                  || pfvalmov || ' pcmovimi: ' || pcmovimi,
                  SQLCODE || '-' || SQLERRM);
      error := 104043;   -- Error al llegir de la taula RECIBOS
      RETURN error;
END;
/
