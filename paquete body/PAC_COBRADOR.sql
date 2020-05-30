--------------------------------------------------------
--  DDL for Package Body PAC_COBRADOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_COBRADOR" IS
/******************************************************************************
   NOMBRE:       pac_cobrado
   PROPÓSITO: Package para el mantenimiento de cobradores bancarios.

   REVISIONES:

   Ver        Fecha        Autor      Descripción
   ---------  ----------  ------      ------------------------------------
     1        29/09/2010   ICV        1. Creación del package
     2        24/01/2011   LCF        2. Control valor nulo del pcbaja en función set_cobrador
     3        22/09/2014   CASANCHEZ  3.0032668: COLM004-Trapaso entre Bancos (cobrador bancario) manteniendo la nómina
******************************************************************************/

   /*************************************************************************
       Nueva función que actualiza la información introducida o modificada del cobrador bancario.
       param pcempres    in : Código de la empresa.
       param PCCOBBAN    IN : Número de cobrador.
       param PCTIPBAN    IN : Código tipo de cuenta
       param PCDOMENT    IN : Código de la Entidad
       param PTSUFIJO    IN : Código Sucursal
       param PNCUENTA    IN : Número de cuenta
       param PCBAJA    IN : Código de baja
       param PCESCRIPCION    IN : Descripción
       param PNNUMNIF    IN : nif
       param CCONTABAN:  Código contable para el cobrador bancario
       param DOM_FILLER_LN3:  Filler para las líneas '3' del fichero de domiciliación
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_set_cobrador(
      pccobban IN NUMBER,
      pncuenta IN VARCHAR2,
      ptsufijo IN VARCHAR2,
      pcempres IN NUMBER,
      pcdoment IN NUMBER,
      pcdomsuc IN NUMBER,
      pnprisel IN NUMBER,
      pcbaja IN NUMBER,
      pdescrip IN VARCHAR2,
      pnnumnif IN VARCHAR2,
      ptcobban IN VARCHAR2,
      pctipban IN NUMBER,
      pccontaban IN NUMBER,
      pdomfill3 IN VARCHAR2,
      pprecimp IN NUMBER,
      pcagruprec IN NUMBER)   -- Bug 19986 - APD - 08/11/2011 - se añade el campo cagruprec
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_COBRADOR.f_set_cobrador';
      vparam         VARCHAR2(500)
         := 'parámetros - pccobban: ' || pccobban || ', pncuenta: ' || pncuenta
            || ' ptsufijo : ' || ptsufijo || ' pcempres : ' || pcempres || ' pcdoment : '
            || pcdoment || ' pcdomsuc : ' || pcdomsuc || ' pnprisel : ' || pnprisel
            || ' pnprisel : ' || pnprisel || ' pcbaja : ' || pcbaja || ' pdescrip : '
            || pdescrip || ' pnnumnif : ' || pnnumnif || ' ptcobban : ' || ptcobban
            || ' pctipban : ' || pctipban || ' pccontaban : ' || pccontaban || ' pdomfill3 : '
            || pdomfill3 || ' precimp : ' || pprecimp || ' pcagruprec :' || pcagruprec;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pccobban IS NULL
         OR pncuenta IS NULL
         OR ptsufijo IS NULL
         OR pcempres IS NULL
         OR pcdoment IS NULL
         OR pcdomsuc IS NULL
         OR pnprisel IS NULL
         OR pctipban IS NULL THEN
         RETURN 103135;
      END IF;

      -- Bug 19986 - APD - 08/11/2011 - se añade el campo cagruprec
      BEGIN
         INSERT INTO cobbancario
                     (ccobban, ncuenta, tsufijo, cempres, cdoment, cdomsuc, nprisel,
                      cbaja, descripcion, nnumnif, tcobban, ctipban, ccontaban,
                      dom_filler_ln3, precimp, cagruprec)
              VALUES (pccobban, pncuenta, ptsufijo, pcempres, pcdoment, pcdomsuc, pnprisel,
                      NVL(pcbaja, 0), pdescrip, pnnumnif, ptcobban, pctipban, pccontaban,
                      pdomfill3, pprecimp, NVL(pcagruprec, 0));
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE cobbancario
               SET ncuenta = pncuenta,
                   tsufijo = ptsufijo,
                   cempres = pcempres,
                   cdoment = pcdoment,
                   cdomsuc = pcdomsuc,
                   nprisel = pnprisel,
                   cbaja = NVL(pcbaja, 0),
                   descripcion = pdescrip,
                   nnumnif = pnnumnif,
                   tcobban = ptcobban,
                   ctipban = pctipban,
                   ccontaban = pccontaban,
                   dom_filler_ln3 = pdomfill3,
                   precimp = pprecimp,
                   cagruprec = NVL(pcagruprec, 0)
             WHERE ccobban = pccobban;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cobrador.f_set_cobrador', 1,
                     'error no controlado', SQLERRM);
         RETURN 108468;
   END f_set_cobrador;

   /*************************************************************************
       Nueva función que valida la información introducida o modificada del cobrador bancario.
       param pcempres    in : Código de la empresa.
       param PCCOBBAN    IN : Número de cobrador.
       param PCTIPBAN    IN : Código tipo de cuenta
       param PCDOMENT    IN : Código de la Entidad
       param PTSUFIJO    IN : Código Sucursal
       param PNCUENTA    IN : Número de cuenta
       param PCBAJA    IN : Código de baja
       param PCESCRIPCION    IN : Descripción
       param PNNUMNIF    IN : nif
       param CCONTABAN:  Código contable para el cobrador bancario
       param DOM_FILLER_LN3:  Filler para las líneas '3' del fichero de domiciliación
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_valida_cobrador(
      pccobban IN NUMBER,
      pncuenta IN VARCHAR2,
      ptsufijo IN VARCHAR2,
      pcempres IN NUMBER,
      pcdoment IN NUMBER,
      pcdomsuc IN NUMBER,
      pnprisel IN NUMBER,
      pcbaja IN NUMBER,
      pdescrip IN VARCHAR2,
      pnnumnif IN VARCHAR2,
      ptcobban IN VARCHAR2,
      pctipban IN NUMBER,
      pccontaban IN NUMBER,
      pdomfill3 IN VARCHAR2,
      pprecimp IN NUMBER,
      pcmodo IN VARCHAR2,
      pcagruprec IN NUMBER)   -- Bug 19986 - APD - 08/11/2011 - se añade el campo cagruprec
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_COBRADOR.f_valida_cobrador';
      vparam         VARCHAR2(500)
         := 'parámetros - pccobban: ' || pccobban || ', pncuenta: ' || pncuenta
            || ' ptsufijo : ' || ptsufijo || ' pcempres : ' || pcempres || ' pcdoment : '
            || pcdoment || ' pcdomsuc : ' || pcdomsuc || ' pnprisel : ' || pnprisel
            || ' pnprisel : ' || pnprisel || ' pcbaja : ' || pcbaja || ' pdescrip : '
            || pdescrip || ' pnnumnif : ' || pnnumnif || ' ptcobban : ' || ptcobban
            || ' pctipban : ' || pctipban || ' pccontaban : ' || pccontaban || ' pdomfill3 : '
            || pdomfill3 || ' precimp : ' || pprecimp || ' pcagruprec :' || pcagruprec;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_dummy        NUMBER := 0;
      num_err        NUMBER := 0;
      v_salida       VARCHAR2(100);
   BEGIN
      IF pccobban IS NULL
         OR pncuenta IS NULL
         OR ptsufijo IS NULL
         OR pcempres IS NULL
         OR pcdoment IS NULL
         OR pcdomsuc IS NULL
         OR pnprisel IS NULL
         OR pctipban IS NULL THEN
         RETURN 103135;
      END IF;

      --Cobrador
      IF pcmodo = 'NUEVO' THEN
         SELECT COUNT('1')
           INTO v_dummy
           FROM cobbancario
          WHERE ccobban = pccobban;

         IF v_dummy <> 0 THEN
            RETURN 9901532;
         END IF;
      END IF;

      --Cuenta bancaria
      num_err := f_formatoccc(pncuenta, v_salida, pctipban, NULL);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cobrador.f_valida_cobrador', 1,
                     'error no controlado', SQLERRM);
         RETURN 108468;
   END f_valida_cobrador;

   /*************************************************************************
       Nueva función que actualiza la información introducida o modificada del cobrador bancario.
       param PCCOBBAN    IN : Número de cobrador.
       param PNORDEN    in : Orden prioridad de selección
       param pcempres    in : Código de la empresa.
       param PCRAMO    IN : Ramo
       param PCMODALI    IN : Modalidad
       param PCTIPSEG    IN : Tipo de seguro
       param PCCOLECT    IN : Colectividad
       param PCBANCO    IN : Código Banco
       param PCTIPAGE    IN : Tipo mediador
       param PCAGENTE    IN :  Mediador
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_set_cobrador_sel(
      pccobban IN NUMBER,
      pnorden IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcempres IN NUMBER,
      pcbanco IN NUMBER,
      pcagente IN NUMBER,
      pctipage IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_COBRADOR.f_set_cobrador_sel';
      vparam         VARCHAR2(500)
         := 'parámetros - pccobban: ' || pccobban || ', pNORDEN: ' || pnorden || ' pCRAMO : '
            || pcramo || ' psproduc : ' || psproduc || ' pCEMPRES : ' || pcempres
            || ' pCBANCO : ' || pcbanco || ' pCAGENTE : ' || pcagente || ' pCTIPAGE : '
            || pctipage;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ccolect      NUMBER;
      v_ctipseg      NUMBER;
      v_ctipage      agentes.ctipage%TYPE;
   BEGIN
      IF pccobban IS NULL
         OR pnorden IS NULL THEN
         RETURN 103135;
      END IF;

      IF pctipage IS NULL
         AND pcagente IS NOT NULL THEN
         SELECT ctipage
           INTO v_ctipage
           FROM agentes
          WHERE cagente = pcagente;
      END IF;

      IF pctipage IS NOT NULL THEN
         v_ctipage := pctipage;
      END IF;

      IF psproduc IS NOT NULL THEN
         SELECT cramo, cmodali, ctipseg, ccolect
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
           FROM productos
          WHERE sproduc = psproduc;

         IF pcramo IS NOT NULL THEN
            v_cramo := pcramo;
         END IF;
      ELSE
         v_cramo := pcramo;
      END IF;

      BEGIN
         INSERT INTO cobbancariosel
                     (ccobban, norden, cramo, ctipseg, cempres, ccolect, cbanco,
                      cmodali, cagente, ctipage)
              VALUES (pccobban, pnorden, v_cramo, v_ctipseg, pcempres, v_ccolect, pcbanco,
                      v_cmodali, pcagente, v_ctipage);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE cobbancariosel
               SET cramo = v_cramo,
                   ctipseg = v_ctipseg,
                   cempres = pcempres,
                   ccolect = v_ccolect,
                   cbanco = pcbanco,
                   cmodali = v_cmodali,
                   cagente = pcagente,
                   ctipage = pctipage
             WHERE ccobban = pccobban
               AND norden = pnorden;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cobrador.f_set_cobrador_sel', 1,
                     'error no controlado', SQLERRM);
         RETURN 108468;
   END f_set_cobrador_sel;

   /*************************************************************************
       Nueva función que valida la información introducida o modificada del cobrador bancario.
       param PCCOBBAN    IN : Número de cobrador.
       param PNORDEN    in : Orden prioridad de selección
       param pcempres    in : Código de la empresa.
       param PCRAMO    IN : Ramo
       param PCMODALI    IN : Modalidad
       param PCTIPSEG    IN : Tipo de seguro
       param PCCOLECT    IN : Colectividad
       param PCBANCO    IN : Código Banco
       param PCTIPAGE    IN : Tipo mediador
       param PCAGENTE    IN :  Mediador
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_valida_cobrador_sel(
      pccobban IN NUMBER,
      pnorden IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcempres IN NUMBER,
      pcbanco IN NUMBER,
      pcagente IN NUMBER,
      pctipage IN NUMBER,
      pcmodo IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_COBRADOR.f_valida_cobrador_sel';
      vparam         VARCHAR2(500)
         := 'parámetros - pccobban: ' || pccobban || ', pNORDEN: ' || pnorden || ' pCRAMO : '
            || pcramo || ' psproduc : ' || psproduc || ' pCEMPRES : ' || pcempres
            || ' pCBANCO : ' || pcbanco || ' pCAGENTE : ' || pcagente || ' pCTIPAGE : '
            || pctipage;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_dummy        NUMBER := 0;
   BEGIN
      IF pccobban IS NULL
         OR pnorden IS NULL THEN
         RETURN 103135;
      END IF;

      IF pcmodo = 'NUEVO' THEN
         SELECT COUNT('1')
           INTO v_dummy
           FROM cobbancariosel
          WHERE norden = pnorden
            AND ccobban = pccobban;

         IF v_dummy <> 0 THEN
            RETURN 9901536;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cobrador.f_valida_cobrador_sel', 1,
                     'error no controlado', SQLERRM);
         RETURN 108468;
   END f_valida_cobrador_sel;

   --
   -- Bug 0032668 Inicio - Se crea la nueva funcion f_traspaso_cobradores
   --
   /*************************************************************************
     Nueva función que reasliza el traspaso de bancos
     param pcempresa      IN  codigo de la empresa
     param pcobbanorigen  IN  cobrador bancario origen
     param pcbanco        IN  codigo de banco a trapasar
     param pcobbandestino IN  cobrador destino
     retorno 0-Correcto, 1-Código error.
    *************************************************************************/
   --
   FUNCTION f_traspaso_cobradores(
      pcempresa IN empresas.cempres%TYPE,
      pcobbanorigen IN cobbancario.ccobban%TYPE,
      pcbanco IN bancos.cbanco%TYPE,
      pcobbandestino IN cobbancario.ccobban%TYPE)
      RETURN NUMBER IS
      --
      CURSOR c_cons_pol_viva(
         pc_pcobbanorigen cobbancario.ccobban%TYPE,
         pc_pcbanco bancos.cbanco%TYPE) IS
         SELECT s.sseguro
           FROM seguros s, tipos_cuenta tc
          WHERE s.ccobban = pc_pcobbanorigen
            AND SUBSTR(s.cbancar, tc.pos_entidad, tc.long_entidad) = pc_pcbanco
            AND 1 = f_situacion_v(psseguro => s.sseguro, pfefecto => s.fefecto)
            AND s.ctipban = tc.ctipban;

      --
      CURSOR c_cons_recibos(
         pc_pcobbanorigen cobbancario.ccobban%TYPE,
         pc_pcbanco bancos.cbanco%TYPE) IS
         SELECT r.nrecibo
           FROM recibos r, seguros s, tipos_cuenta tc, movrecibo mr
          WHERE r.ccobban = pc_pcobbanorigen
            AND SUBSTR(s.cbancar, tc.pos_entidad, tc.long_entidad) = pc_pcbanco
            AND 1 = f_situacion_v(psseguro => s.sseguro, pfefecto => s.fefecto)
            AND s.ctipban = tc.ctipban
            AND r.sseguro = s.sseguro
            AND mr.smovrec = r.nrecibo
            AND mr.cestrec = 0
            AND mr.cestant IN(0, 1, 3);

      --
      CURSOR c_cons_estado_cobbanc(pc_pcobbandestino cobbancario.ccobban%TYPE) IS
         SELECT c.ccobban
           FROM cobbancario c
          WHERE c.ccobban = pc_pcobbandestino
            AND c.cbaja <> 1;

      --
      CURSOR c_cons_bancos(
         pc_pcobbanorigen cobbancario.ccobban%TYPE,
         pc_pcbanco bancos.cbanco%TYPE) IS
         SELECT c.ccobban
           FROM cobbancariosel c
          WHERE c.ccobban = pc_pcobbanorigen
            AND c.cbanco = pc_pcbanco;

      --
      vobjectname    VARCHAR2(500) := 'PAC_COBRADOR.f_traspaso_cobradores';
      vparam         VARCHAR2(500) := 'parámetros -  pcbanco :' || pcbanco;
      --
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      --
      vpolviva       seguros.sseguro%TYPE;
      vrecibo        recibos.nrecibo%TYPE;
      --
      vestadocobbanc cobbancario.cbaja%TYPE;
      vbancoasig     cobbancariosel.ccobban%TYPE;
   --
   BEGIN
      --
      IF pcobbanorigen IS NULL
         OR pcobbandestino IS NULL
         OR pcbanco IS NULL
         OR pcempresa IS NULL THEN
         --
         p_tab_error(pferror => f_sysdate, pcusuari => f_user, ptobjeto => vobjectname,
                     pntraza => vpasexec, ptdescrip => 'error controlado', pterror => SQLERRM);
         --
         RETURN 108376;
      --
      ELSE
         --
         OPEN c_cons_estado_cobbanc(pc_pcobbandestino => pcobbandestino);

         --
         FETCH c_cons_estado_cobbanc
          INTO vestadocobbanc;

         --
         IF c_cons_estado_cobbanc%FOUND THEN
            --
            OPEN c_cons_bancos(pc_pcobbanorigen => pcobbanorigen, pc_pcbanco => pcbanco);

            --
            FETCH c_cons_bancos
             INTO vbancoasig;

            --
            IF c_cons_bancos%FOUND THEN
               --
               --Realiza el traspazo de bancos (POR EL MOMENTO NO SE REALIZA)
               --
               /*UPDATE cobbancariosel a
                  SET a.norden = (SELECT MAX(b.norden) + 1
                                    FROM cobbancariosel b
                                   WHERE b.ccobban = pcobbandestino),
                      a.ccobban = pcobbandestino
                WHERE a.ccobban = pcobbanorigen
                  AND a.cbanco = pcbanco;*/

               --
               --Realiza el traspazo de polizas vivas
               --
               OPEN c_cons_pol_viva(pc_pcobbanorigen => pcobbanorigen, pc_pcbanco => pcbanco);

               --
               FETCH c_cons_pol_viva
                INTO vpolviva;

               --
               WHILE c_cons_pol_viva%FOUND LOOP
                  --
                  UPDATE seguros s
                     SET s.ccobban = pcobbandestino
                   WHERE s.sseguro = vpolviva;

                  --
                  FETCH c_cons_pol_viva
                   INTO vpolviva;
               --
               END LOOP;

               --
               CLOSE c_cons_pol_viva;

               --
               --Realiza el traspaso de mandatos
               --
               UPDATE mandatos
                  SET ccobban = pcobbandestino
                WHERE ccobban = pcobbanorigen;

               --
               --Realiza el traspaso de recibos pendientes
               --
               OPEN c_cons_recibos(pc_pcobbanorigen => pcobbanorigen, pc_pcbanco => pcbanco);

               --
               FETCH c_cons_recibos
                INTO vrecibo;

               --
               WHILE c_cons_recibos%FOUND LOOP
                  --
                  UPDATE recibos r
                     SET r.ccobban = pcobbandestino
                   WHERE r.nrecibo = vrecibo;

                  --
                  FETCH c_cons_recibos
                   INTO vpolviva;
               --
               END LOOP;

               --
               CLOSE c_cons_recibos;

               --
               RETURN 0;
            --
            ELSE
               --
               p_tab_error(pferror => f_sysdate, pcusuari => f_user, ptobjeto => vobjectname,
                           pntraza => vpasexec, ptdescrip => 'error controlado',
                           pterror => SQLERRM);
               --
               RETURN 9907078;
            --
            END IF;

            --
            CLOSE c_cons_bancos;
         --
         ELSE
            --
            p_tab_error(pferror => f_sysdate, pcusuari => f_user, ptobjeto => vobjectname,
                        pntraza => vpasexec, ptdescrip => 'error controlado',
                        pterror => SQLERRM);
            --
            RETURN 9907077;
         --
         END IF;

         --
         CLOSE c_cons_estado_cobbanc;
      --
      END IF;
   --
   EXCEPTION
      WHEN OTHERS THEN
         --
         p_tab_error(pferror => f_sysdate, pcusuari => f_user, ptobjeto => vobjectname,
                     pntraza => vpasexec, ptdescrip => 'error no controlado',
                     pterror => SQLERRM);
         --
         RETURN 108468;
   --
   END f_traspaso_cobradores;

--
-- Bug 0032668 Fin
--
   FUNCTION ff_buscacobban(
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcagente IN NUMBER,
      pcbancar IN VARCHAR2,
      pctipban IN NUMBER,
      pgenerr IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      --
      -- Bug 0035181 - 200356 - JMF - 08/04/2015 - llamada función sin param salida
      vobj           VARCHAR2(500) := 'PAC_COBRADOR.f_buscacobban';
      vpar           VARCHAR2(500)
         := 'parámetros -  r=' || pcramo || ' m=' || pcmodali || ' t=' || pctipseg || ' c='
            || pccolect || ' a=' || pcagente || ' b=' || pcbancar || ' t=' || pctipban
            || ' g=' || pgenerr;
      vpas           NUMBER(5) := 1;
      verr           NUMBER(8) := 0;
      vcob           cobbancario.ccobban%TYPE;
   BEGIN
      vcob := f_buscacobban(pcramo, pcmodali, pctipseg, pccolect, pcagente, pcbancar,
                            pctipban, verr);

      IF verr <> 0 THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN vcob;
   EXCEPTION
      WHEN OTHERS THEN
         IF pgenerr = 1 THEN
            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                        'e=' || verr || ' s=' || SQLCODE || ' m=' || SQLERRM);
         END IF;

         RETURN NULL;
   END ff_buscacobban;
END pac_cobrador;

/

  GRANT EXECUTE ON "AXIS"."PAC_COBRADOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_COBRADOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_COBRADOR" TO "PROGRAMADORESCSI";
