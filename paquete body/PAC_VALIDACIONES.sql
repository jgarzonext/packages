--------------------------------------------------------
--  DDL for Package Body PAC_VALIDACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_VALIDACIONES" AS
/******************************************************************************
   NOMBRE:      PAC_VALIDACIONES
   PROPÓSITO: Funciones para las validaciónes

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/06/2011   APD             1. Creación del package.
   2.0        17/11/2011   JMC             2. 0019303: LCOL_T003-Analisis Polissa saldada/prorrogada. LCOL_TEC_ProductosBrechas04
   3.0        27/12/2012   ECP             3. 0025450: LCOL_T001-QT-5394 - El sistema no permite realizar un reemplazo si la p?liza tiene recibos pendientes
   4.0        31/01/2013   JLTS            4. 0025888/136500: LCOL_T001-LCOL - Corregir e implantar mensajes de error en proceso de saldado/prorrogado en la funcion f_valida_sp
   5.0        04/03/2013   AEG             5. 0024685: (POSDE600)-Desarrollo-GAPS Tecnico-Id 5 -- N?mero de p?liza manual
   6.0        02/08/2013   RCL             6. 0024721: (POSDE600)-Desarrollo-GAPS Tecnico-Id 4 - Numero de solicitud preimpreso
   7.0        25/11/2013   JSV             7. 0028455: LCOL_T031- TEC - Revisión Q-Trackers Fase 3A II
   8.0        16/01/2014   MMS             8. 0027305: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Conmutacion Pensional
******************************************************************************/

   /*************************************************************************
      FUNCTION f_vigencia_simul
         Valida el periodo de vigencia de una simulacion
         param in psseguro     : secuencia seguro
         param in pnmovimi     : numero de movimiento
         return                : 0 -> Tot correcte
                                 1 -> S'ha produit un error
   *************************************************************************/
   -- Bug 18848 - APD - 27/06/2011 - se crea la funcion
   -- Bug 24272 - JMC - 07/11/2012 - Reemplazo masivo de colectivos
   FUNCTION f_vigencia_simul(psseguro IN NUMBER, pnmovimi IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_validaciones.f_vigencia_simul';
      vparam         VARCHAR2(500)
                          := 'parámetros - psseguro: ' || psseguro || ' pnmovimi:' || pnmovimi;
      vpasexec       NUMBER(5) := 1;
      vftarifa       estgaranseg.ftarifa%TYPE;
      vsproduc       seguros.sproduc%TYPE;
      vdiasvigen     NUMBER;
      num_err        NUMBER;
      vcrespue       NUMBER;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psseguro IS NULL THEN
         RETURN 111995;   --Es obligatorio informar el número de seguro
      END IF;

      vpasexec := 2;

      BEGIN
         SELECT sproduc
           INTO vsproduc
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 140720;   -- Error al obtener el código de producto
      END;

      vpasexec := 3;

      IF NVL(f_parproductos_v(vsproduc, 'FECHA_TARIFA'), 1) = 2 THEN   --Fecha de grabación inicial
         vdiasvigen := NVL(f_parproductos_v(vsproduc, 'VIG_FECHA_TARIFA'), 0);
         vpasexec := 4;

         IF vdiasvigen <> 0 THEN
            -- BUG27304:DRA:14/11/2013:Inici: Si tiene fecha de cotización usamos ésta
            num_err := pac_preguntas.f_get_pregunpolseg(psseguro, 8900, 'EST', vcrespue);

            IF vcrespue IS NOT NULL THEN
               vftarifa := TO_DATE(vcrespue, 'YYYYMMDD');
            ELSE
               BEGIN
                  SELECT MIN(ftarifa)
                    INTO vftarifa
                    FROM estgaranseg
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 103500;   -- Error al leer de la tabla GARANSEG
               END;
            END IF;

            -- BUG27304:DRA:14/11/2013:Fi
            vpasexec := 5;

            IF TRUNC(f_sysdate) > TRUNC(vftarifa) + vdiasvigen THEN
               --No es posible continuar con la simulación porque ha sobrepasado el periodo de vigencia de la tarifa, tiene la posibilidad de duplicar la simulación o iniciar el proceso de nuevo.'
               RETURN 9902151;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;   --Error no controlado.
   END f_vigencia_simul;

   -- INICIO BUG 19276, JBN, REEMPLAZOS
   /*************************************************************************
      Función nueva que valida si una póliza puede ser reemplazada
      param in PSSEGURO    : Identificador del seguro a reemplazaar
      param in PSPRODUC    : Identificador del producto de la póliza nueva
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_reemplazo(psseguro IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_validaciones.f_valida_reemplazo';
      vparam         VARCHAR2(500)
                          := 'parámetros - psseguro: ' || psseguro || ' psproduc:' || psproduc;
      vpasexec       NUMBER(5) := 1;
      vcsituac       NUMBER;
      vsprodreemp    NUMBER;
      vcont          NUMBER;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psseguro IS NULL THEN
         RETURN 111995;   --Es obligatorio informar el número de seguro
      END IF;

      --Comprovació dels parámetres d'entrada
      IF psproduc IS NULL THEN
         RETURN 103135;   --Faltan parámetros
      END IF;

      vpasexec := 2;

      BEGIN
         SELECT csituac
           INTO vcsituac
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 103286;   -- LA PÓLIZA NO EXISTE
      END;

      IF vcsituac <> 0 THEN
         RETURN 9902369;   --LA PÓLIZA A REEMPLAZAR DEBE ESTAR VIGENTE
      END IF;

      vpasexec := 3;

      BEGIN
         SELECT sproduc
           INTO vsprodreemp
           FROM seguros
          WHERE sseguro = psseguro;

         SELECT COUNT(1)
           INTO vcont
           FROM productos_reemplazo
          WHERE sproduc = psproduc
            AND sprodreemp = vsprodreemp;

         IF vcont = 0 THEN
            RETURN 9902370;   --l producto de la póliza a reemplazar no es compatible con el producto de la nueva póliza
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 103286;   -- La póliza no existe
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;   --Error no controlado.
   END f_valida_reemplazo;

   /*************************************************************************
      valida si una póliza puede ser reemplazada
      param in PSSEGURO    : Identificador del seguro a reemplazaar
      param in PSPRODUC    : Fecha de efecto de la póliza
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_gestion_reemplazo(psseguro IN NUMBER, pfefecto IN DATE)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_validaciones.F_VALIDA_GESTION_REEMPLAZO';
      vparam         VARCHAR2(500)
                          := 'parámetros - psseguro: ' || psseguro || ' pfefecto:' || pfefecto;
      vpasexec       NUMBER(5) := 1;
      vdate          DATE;
      vdate2         DATE;
      vcont          NUMBER;
      vsproduc       NUMBER;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF psseguro IS NULL THEN
         RETURN 111995;   --Es obligatorio informar el número de seguro
      END IF;

      --Comprovació dels parámetres d'entrada
      IF pfefecto IS NULL THEN
         RETURN 103135;   --Faltan parámetros
      END IF;

      vpasexec := 2;

      BEGIN
         SELECT fvencim
           INTO vdate
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 103286;   -- LA PÓLIZA NO EXISTE
      END;

      IF vdate IS NOT NULL
         AND pfefecto > vdate THEN
         RETURN 9902372;   --La fecha de efecto introducida no debe ser superior a la fecha de vencimiento de la póliza a reemplazar.
      END IF;

      vpasexec := 3;

      BEGIN
         SELECT fcaranu, fcarpro, sproduc
           INTO vdate, vdate2, vsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 103286;   -- LA PÓLIZA NO EXISTE
      END;

      -- INICIO BUG 24272 - JMC - 07/11/2012 - Reemplazo masivo colectivos.
      IF NVL(pac_parametros.f_parproducto_n(vsproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
         IF (vdate IS NOT NULL
             AND pfefecto > vdate)
            OR(vdate2 IS NOT NULL
               AND pfefecto > vdate2) THEN
            RETURN 9902373;   --LLa fecha de efecto no puede ser superior a la fecha de renovación de la póliza a reemplazar
         END IF;
      /*ELSE
         IF (vdate IS NOT NULL
             AND pfefecto > vdate) THEN
            RETURN 9902373;   --LLa fecha de efecto no puede ser superior a la fecha de renovación de la póliza a reemplazar
         END IF;*/
      END IF;

      -- FIN BUG 24272 - JMC - 07/11/2012
      vpasexec := 4;

      BEGIN
         SELECT MIN(fefecto)
           INTO vdate
           FROM recibos r, movrecibo m
          WHERE r.nrecibo = m.nrecibo
            AND m.cestrec = 3
            AND m.fmovfin IS NULL
            AND r.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 103286;   -- LA PÓLIZA NO EXISTE
      END;

      IF (vdate IS NOT NULL)
         AND vdate <> pfefecto THEN
         RETURN 9902437;   --'La fecha de efecto de la propuesta debe ser igual a la mínima fecha de efecto de los recibos remesados
      END IF;

      FOR cur IN (SELECT m.cestsin
                    FROM sin_siniestro s, sin_movsiniestro m
                   WHERE s.nsinies = m.nsinies
                     AND m.nmovsin = (SELECT MAX(m2.nmovsin)
                                        FROM sin_movsiniestro m2
                                       WHERE m2.nsinies = m.nsinies)
                     AND s.fsinies >= pfefecto
                     AND s.sseguro = psseguro) LOOP
         IF cur.cestsin IN(0, 1) THEN
            RETURN 9902374;
         END IF;
      END LOOP;

      IF NVL(pac_parametros.f_parproducto_n(vsproduc, 'ADMITE_CERTIFICADOS'), 0) <> 1 THEN
         SELECT COUNT(1)
           INTO vcont
           FROM movrecibo m, recibos r
          WHERE m.nrecibo = r.nrecibo
            AND m.fmovfin IS NULL
            AND m.cestrec = 0
            AND r.sseguro = psseguro
            AND r.fefecto < pfefecto;   -- Bug.25450  -- ECP -- 27/12/2012 Recibos pendientes  que tengan fecha efecto anterior a la fecha de efecto del nuevo reemplazo

         IF vcont > 0 THEN
            RETURN 9902375;   -- La póliza a reemplazar tiene recibos pendientes
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;   --Error no controlado.
   END f_valida_gestion_reemplazo;

-- FIN BUG 19276, JBN, REEMPLAZOS
-- INICIO BUG 19303 - JMC - 17/11/2011 - Saldar / Prorrogar póliza.
   /*************************************************************************
      valida si una póliza está en situación de ser saldada o prorrogada.
      param in PSSEGURO    : Identificador del seguro a reemplazaar
      param out mensajes : mensajes de error
      return             : 0 la validación ha sido correcta
                           1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_sp(psseguro IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_validaciones.f_valida_sp';
      vparam         VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vcsituac       seguros.csituac%TYPE;
      vcreteni       seguros.creteni%TYPE;
      vsproduc       seguros.sproduc%TYPE;
      vcempres       empresas.cempres%TYPE;
      vcvalorsal     NUMBER;
      vcvalorpro     NUMBER;
      vcvalor        NUMBER;
      vnumret        NUMBER := 0;
   BEGIN
      SELECT s.csituac, s.creteni, s.sproduc
        INTO vcsituac, vcreteni, vsproduc
        FROM seguros s
       WHERE s.sseguro = psseguro;

      vcvalorsal := pac_parametros.f_parproducto_n(vsproduc, 'PERMITE_SALDAR');
      vcvalorpro := pac_parametros.f_parproducto_n(vsproduc, 'PERMITE_PRORROGAR');

      IF vcvalorsal = 0
         AND vcvalorpro = 0 THEN
         RETURN 9903547;
      END IF;

      vnumret := pac_seguros.f_es_migracion(psseguro, 'POL', vcvalor);

      IF vnumret != 0 THEN
         RETURN vnumret;
      END IF;

      IF vcvalor = 0 THEN
         BEGIN
            SELECT 1
              INTO vcvalor
              FROM recibos r, movrecibo m
             WHERE r.sseguro = psseguro
               AND r.nrecibo = m.nrecibo
               AND m.fmovfin IS NULL
               AND m.cestrec = 1;   -- Cobrado
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcvalor := 0;   -- No tiene recibos codrados
         END;
      END IF;

      IF vcvalor = 0 THEN
         RETURN 9904795;
      END IF;

      IF vcsituac = 0
         AND vcreteni = 0 THEN   --Vigente, sin retener, situación OK
         RETURN 0;
      ELSE
         RETURN 120129;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;   --Error no controlado.
   END f_valida_sp;

-- FIN BUG 19303 - JMC - 17/11/2011

   /*************************************************************************
      -- BUG 25143 - XVM - 20/12/2012
      f_valida_campo: valida si el valor de un campo en concreto contiene algún carácter no permitido
      param in pcempres    : Código empresa
      param in pcidcampo    : Campo a validar
      param in pcampo    : Texto introducido a validar
      return             : 0 validación correcta
                           <>0 validación incorrecta
   *************************************************************************/
   FUNCTION f_valida_campo(pcempres IN NUMBER, pcidcampo IN VARCHAR2, pcampo IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_validaciones.f_valida_campo';
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ' pcidcampo: ' || pcidcampo
            || ' pcampo: ' || pcampo;
      vpasexec       NUMBER(5) := 1;
      v_textoinc     obformato.textoinc%TYPE;
      v_tamanyo      obformato.tamanyo%TYPE;
      v_aux          NUMBER;
      v_caracter     VARCHAR2(1);
      i              NUMBER(5) := 1;
   BEGIN
      BEGIN
         SELECT textoinc, tamanyo
           INTO v_textoinc, v_tamanyo
           FROM obformato
          WHERE cempres = pcempres
            AND cidcampo = pcidcampo;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 0;
      END;

      IF LENGTH(pcampo) > v_tamanyo THEN
         RETURN 50000;   --Formato incorrecto
      ELSE
         WHILE i <= LENGTH(v_textoinc) LOOP
            v_caracter := SUBSTR(v_textoinc, i, 1);
            v_aux := INSTR(pcampo, v_caracter);

            IF v_aux > 0 THEN
               RETURN 50000;   --Formato incorrecto
            END IF;

            i := i + 1;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;   --Error no controlado.
   END f_valida_campo;

   /*************************************************************************
        Bug: 24685 2013-02-06 AEG
        Función que valida numeracion de poliza manual. Preimpresos.
        mensajes : mensajes de error
        return             : 0 la validaciÃ³n ha sido correcta
                             1 la validaciÃ³n no ha sido correcta
     *************************************************************************/
   FUNCTION f_valida_polizamanual(
      ptipasignum NUMBER,
      pnpolizamanual NUMBER,
      psseguro NUMBER,
      psproduc NUMBER,
      pcempres NUMBER,
      pcagente NUMBER,
      ptablas VARCHAR2)
      RETURN NUMBER IS
      v_nada         NUMBER(1);
      vobjectname    VARCHAR2(500) := 'pac_validaciones.f_valida_polizamanual';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros -' || ' ptipasignum : ' || ptipasignum || ' pnpolizamanual : '
            || pnpolizamanual || ' psseguro : ' || psseguro || ' psproduc : ' || psproduc
            || ' pcempres : ' || pcempres || ' pcagente : ' || pcagente || ' ptablas : '
            || ptablas;
   BEGIN
      -- Diferente de Manual Retorna
      IF ptipasignum != 1 THEN
         RETURN 0;
      END IF;

--  SELECT * FROM TAB_ERROR ORDER BY 7 DESC
      BEGIN
         SELECT 1
           INTO v_nada
           FROM reserva_rangos
          WHERE pnpolizamanual BETWEEN inirango AND finrango
            AND cramo = (SELECT cramo
                           FROM productos
                          WHERE sproduc = psproduc)
            AND csucursal =
                  NVL(pac_redcomercial.f_busca_padre(NVL(pcempres,
                                                         pac_md_common.f_get_cxtempresa),
                                                     NVL(pcagente,
                                                         pac_md_common.f_get_cxtagente),
                                                     NULL, f_sysdate),
                      NVL(pcagente, pac_md_common.f_get_cxtagente))
            AND bloqueo = 0
            AND ctipo = 2;   --rango de polizas
      EXCEPTION
         WHEN OTHERS THEN
            -- La numeracion de la poliza no esta comprendida entre los rangos asignados a ese ramo
            RETURN 9905011;
      END;

      IF ptablas = 'EST' THEN
         --Comprobamos que ese npoliza no este ya en las estseguros.
         FOR r IN (SELECT 1
                     FROM estseguros
                    WHERE npolizamanual = pnpolizamanual
                      AND sseguro <> psseguro) LOOP
            -- numero de poliza ya esta siendo utlizado en otra alta de poliza
            RETURN 9905012;
         END LOOP;
      END IF;

      -- Se reorganiza el codigo ya que el select de seguros se ejecuta siempre : ptablas EST, null, POL
      FOR r IN (SELECT 1
                  FROM seguros
                 WHERE npoliza = pac_prod_comu.f_obtener_polizamanual(psproduc, pnpolizamanual)
                   AND sseguro NOT IN(SELECT est.ssegpol
                                        FROM estseguros est
                                       WHERE est.sseguro = psseguro)) LOOP
         RETURN 9905013;   -- numero de poliza ya existe
      END LOOP;

      -- TODO OK
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         --Error no controlado.
         RETURN 1000455;
   END f_valida_polizamanual;

   /*************************************************************************
   Bug: 24685 2013-02-06 AEG
   Función que valida numeracion de poliza manual. Preimpresos.
   mensajes : mensajes de error
   return             : 0 la validaciÃ³n ha sido correcta
                       1 la validaciÃ³n no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_npreimpreso(
      pnpreimpreso NUMBER,
      psseguro NUMBER,
      psproduc NUMBER,
      pcempres NUMBER,
      pcagente NUMBER,
      ptablas VARCHAR2)
      RETURN NUMBER IS
      v_nada         NUMBER(1);
      mensajes       t_iax_mensajes;
   BEGIN
      BEGIN
         SELECT 1
           INTO v_nada
           FROM reserva_rangos
          WHERE pnpreimpreso BETWEEN inirango AND finrango
            AND cramo = (SELECT cramo
                           FROM productos
                          WHERE sproduc = psproduc)
            AND csucursal =
                  NVL
                     (pac_redcomercial.f_busca_padre
                          (NVL(pcempres, pac_md_common.f_get_cxtempresa),
                           NVL(pcagente, pac_md_common.f_get_cxtagente),
                           pac_parametros.f_parempresa_n(NVL(pcempres,
                                                             pac_md_common.f_get_cxtempresa),
                                                         'CTIPAGE_PREIMPRESO'),
                           f_sysdate),
                      NVL(pcagente, pac_md_common.f_get_cxtagente))
            AND bloqueo = 0
            AND ctipo = 1;   -- rango de propuestas
      EXCEPTION
         WHEN OTHERS THEN
            -- La numeracion del preimpreso no esta comprendida entre los rangos asignados a ese ramo
            RETURN 9905016;
      END;

      IF ptablas = 'EST' THEN
         --Comprobamos que esa solicitud no este ya en las estseguros
         FOR r IN (SELECT 1
                     FROM estseguros
                    WHERE nsolici = pnpreimpreso
                      AND sseguro <> psseguro) LOOP
            -- Este numero de solitud ya esta siendo utlizado en otra  simulacion
            RETURN 9905017;
         END LOOP;
      END IF;

      FOR r IN (SELECT 1
                  FROM seguros
                 WHERE nsolici = pnpreimpreso
                   AND sseguro NOT IN(SELECT est.ssegpol
                                        FROM estseguros est
                                       WHERE est.sseguro = psseguro)) LOOP
         -- Este numero de solicitud ya existe
         RETURN 9905117;
      END LOOP;

      RETURN 0;   -- todo ok
   END f_valida_npreimpreso;

-- Bug 28455/0159543 - JSV - 25/11/2013
--   FUNCTION f_validaasegurados_nomodifcar(psperson IN NUMBER)
   FUNCTION f_validaasegurados_nomodifcar(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pssegpol IN NUMBER)
      RETURN NUMBER IS
      v_nada         NUMBER(1);
      vobjectname    VARCHAR2(500) := 'pac_validaciones.f_validaasegurados_nomodifcar';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(500) := 'parámetros -' || ' psperson : ' || psperson;
      vcont          NUMBER;
   BEGIN
         -- Bug 28455/0159543 - JSV - 25/11/2013 - INI
         /*   SELECT COUNT(1)
              INTO vcont
              FROM estassegurats
             WHERE sperson = psperson
               AND ffecfin IS NULL;
      */
      SELECT COUNT(1)
        INTO vcont
        FROM estassegurats ea, estseguros s, seguros ss
       WHERE sperson = psperson
         AND ea.sseguro = psseguro
         AND s.ssegpol = pssegpol
         AND s.ssegpol = ss.sseguro
         AND s.sseguro = psseguro
         AND ffecfin IS NULL;

-- Bug 28455/0159543 - JSV - 25/11/2013 - FIN
      IF vcont = 0 THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         --Error no controlado.
         RETURN 1000455;
   END f_validaasegurados_nomodifcar;

-- Inicio BUG 27305 MMS 20140116
  /*************************************************************************
      FUNCTION f_esclausulacertif0
         Valida si una clausula pertenece al certificado 0 en un hijo y,
         por lo tanto, no se puede ni borrar ni modificar.
         param in psseguro     : secuencia seguro
         param in pmode        : si es de tipo EST o POL
         param in pnordcla     : identif. de clausula
         return                : 0 -> Tot correcte
                                 1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_esclausulacertif0(
      psseguro IN NUMBER,
      pmode IN VARCHAR2,
      pnordcla IN NUMBER,
      ptclaesp IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_VALIDACIONES.F_ESCLAUSULACERTIF0';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' pmode:' || pmode || ' pnordcla:'
            || pnordcla || ' ptclaesp:' || SUBSTR(ptclaesp, 1, 200);
      vpasexec       NUMBER(5) := 1;
      vnpoliza       NUMBER;
      vsproduc       NUMBER;
      vssegpol       NUMBER;
      vncertif       NUMBER;
      vnum           NUMBER;
      verror         NUMBER;
      v_clausula     NUMBER;
      escertif0      BOOLEAN := FALSE;

      CURSOR cclauesp_cert0(pnpoliza NUMBER) IS
         SELECT c.*
           FROM clausuesp c, seguros s
          WHERE s.npoliza = pnpoliza
            AND s.ncertif = 0
            AND c.sseguro = s.sseguro
            AND c.cclaesp = 2
            AND c.ffinclau IS NULL;
   BEGIN
      IF pmode = 'EST' THEN
         SELECT npoliza, sproduc, ssegpol
           INTO vnpoliza, vsproduc, vssegpol
           FROM estseguros
          WHERE sseguro = psseguro;

         SELECT COUNT(1)
           INTO vnum
           FROM seguros
          WHERE sseguro = vssegpol
            AND ncertif = 0;

         IF vnum = 1 THEN
            escertif0 := TRUE;
         END IF;
      ELSE
         SELECT npoliza, sproduc, ncertif
           INTO vnpoliza, vsproduc, vncertif
           FROM seguros
          WHERE sseguro = psseguro;

         IF vncertif = 0 THEN
            escertif0 := TRUE;
         END IF;
      END IF;

      vpasexec := 1;

      IF NOT escertif0 THEN
         IF NVL(pac_iaxpar_productos.f_get_parproducto('ADMITE_CERTIFICADOS', vsproduc), 0) =
                                                                                             1 THEN
            verror := pac_productos.f_get_herencia_col(vsproduc, 4, v_clausula);
            vpasexec := 2;

            IF NVL(v_clausula, 0) IN(2, 3)
               AND verror = 0 THEN
               vpasexec := 3;

               FOR claucert0 IN cclauesp_cert0(vnpoliza) LOOP
                  IF claucert0.tclaesp = ptclaesp THEN
                     vpasexec := 4;
                     RETURN 9906422;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;   --Error no controlado.
   END f_esclausulacertif0;

-- Fin BUG 27305

   -- Bug 31208/176812 - AMC - 06/06/2014
   FUNCTION f_validamodi_plan(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER   -- Bug 31686/179633 - 16/07/2014 - AMC
                        )
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_validaciones.f_validamodi_plan';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros -' || ' psseguro:' || psseguro || ' pnriesgo:' || pnriesgo
            || ' pnmovimi:' || pnmovimi;
      vcont          NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO vcont
        FROM estriesgos er, riesgos r, estseguros es
       WHERE es.sseguro = psseguro
         AND er.sseguro = es.sseguro
         AND es.ssegpol = r.sseguro
         AND r.nriesgo = er.nriesgo
         AND er.nriesgo = pnriesgo
         AND er.nmovima = pnmovimi;   -- Bug 31686/179633 - 16/07/2014 - AMC

      IF vcont = 0 THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         --Error no controlado.
         RETURN 1000455;
   END f_validamodi_plan;

-- BUG 0033510 - FAL - 19/11/2014
   /*************************************************************************
      Valida exista al menos un titular y éste tenga todas las garantías contratadas por los dependientes
      param IN psseguro: sseguro
      param IN pnmovimi: nmovimi
      return :  0 todo correcto
                <>0 validación incorrecta
   *************************************************************************/
   FUNCTION f_validar_titular_salud(psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_validaciones.f_validar_titular_salud';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(500)
                     := 'parámetros -' || ' psseguro:' || psseguro || ' pnmovimi:' || pnmovimi;
      vcont          NUMBER;
      w_numtitulares NUMBER := 0;
      w_gars_no_titular NUMBER := 0;
   BEGIN
      SELECT COUNT(1)
        INTO w_numtitulares
        FROM estpregunseg
       WHERE sseguro = psseguro
         AND nmovimi = pnmovimi
         AND cpregun = 505
         AND crespue = 0;

      IF w_numtitulares <> 1 THEN
         RETURN 9905806;
      END IF;

      SELECT COUNT(1)
        INTO w_gars_no_titular
        FROM (SELECT cgarant
                FROM estgaranseg g, estpregunseg p
               WHERE g.sseguro = psseguro
                 AND g.nmovimi = pnmovimi
                 AND g.sseguro = p.sseguro
                 AND g.nriesgo = p.nriesgo
                 AND g.nmovimi = p.nmovimi
                 AND p.cpregun = 505
                 AND p.crespue <> 0
                 AND g.cobliga = 1
              MINUS
              SELECT cgarant
                FROM estgaranseg g, estpregunseg p
               WHERE g.sseguro = psseguro
                 AND g.nmovimi = pnmovimi
                 AND g.sseguro = p.sseguro
                 AND g.nriesgo = p.nriesgo
                 AND g.nmovimi = p.nmovimi
                 AND p.cpregun = 505
                 AND p.crespue = 0
                 AND g.cobliga = 1);

      IF w_gars_no_titular <> 0 THEN
         RETURN 9907323;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         --Error no controlado.
         RETURN 1000455;
   END f_validar_titular_salud;
-- FI BUG 0033510 - FAL - 19/11/2014
END pac_validaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_VALIDACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VALIDACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VALIDACIONES" TO "PROGRAMADORESCSI";
