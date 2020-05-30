--------------------------------------------------------
--  DDL for Package Body PAC_OUTSOURCING_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_OUTSOURCING_CONF" IS
   /******************************************************************************
      NOMBRE:    PAC_OUTSOURCING_CONF
      PROP¿SITO: Funciones para carga de facturas de outsourcing

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        02/03/2016  JAE              1. Creaci¿n del objeto.

   ******************************************************************************/
   --
   --Cursor de recibos cobrados
   CURSOR c_recibos_cobrados(p_npoliza NUMBER) IS
      SELECT s.sproduc,
             s.npoliza,
             s.sseguro,
             r.nrecibo,
             v.itotalr,
             r.fefecto,
             m.fmovini,
             m.fmovini - r.fefecto dias_cartera
        FROM recibos     r,
             seguros     s,
             movrecibo   m,
             vdetrecibos v
       WHERE r.sseguro = s.sseguro
         AND r.nrecibo = m.nrecibo
         AND r.nrecibo = v.nrecibo
         AND r.cgescar = 2 --Gestion OUTSOURCING
         AND m.smovrec = (SELECT MAX(mr.smovrec)
                            FROM movrecibo mr
                           WHERE mr.nrecibo = m.nrecibo)
         AND m.cestrec = 1
         AND s.npoliza = p_npoliza
         AND NOT EXISTS (SELECT nrecibo
                FROM gest_liquidalin g
               WHERE g.nrecibo = r.nrecibo);

   --
   /*************************************************************************
      FUNCTION f_retefuente

      param in pcoutsour    : C¿digo OUTSOURCING
      param in pfecha       : Fecha
      return                : NUMBER
   *************************************************************************/
   --
   FUNCTION f_retefuente(pcoutsour IN NUMBER) RETURN NUMBER IS
      --
      vvalor NUMBER;
      --
   BEGIN
      SELECT DECODE(r.cregfiscal,
                    5,
                    0,
                    6,
                    0,
                    8,
                    0,
                    9,
                    0,
                    11,
                    0,
                    DECODE(p.ctipper, 1, 1, 2))
        INTO vvalor
        FROM gest_outsourcing g,
             per_personas p,
             (SELECT sperson,
                     cregfiscal
                FROM per_regimenfiscal
               WHERE (sperson, fefecto) IN
                     (SELECT sperson,
                             MAX(fefecto)
                        FROM per_regimenfiscal
                       GROUP BY sperson)) r
       WHERE g.coutsour = pcoutsour
         AND p.sperson = g.sperson
         AND p.sperson = r.sperson(+);
      --
      RETURN vtramo(-1, 800064, vvalor) / 100;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         RETURN 0;
         --
   END f_retefuente;

   --
   /*************************************************************************
      FUNCTION f_reteica_indicador

      param in pcoutsour    : C¿digo OUTSOURCING
      param in pfecha       : Fecha
      return                : NUMBER
   *************************************************************************/
   --
   FUNCTION f_reteica_indicador(pcoutsour IN NUMBER) RETURN NUMBER IS
      --
      vcprovin NUMBER;
      vcpoblac NUMBER;
      vvalor   NUMBER;
      --
   BEGIN
      SELECT DECODE(r.cregfiscal, 4, 0, 5, 0, 7, 0, 8, 0, 12, 0, a.cprovin) cprovin,
             DECODE(r.cregfiscal, 4, 0, 5, 0, 7, 0, 8, 0, 12, 0, a.cpoblac) cpoblac
        INTO vcprovin,
             vcpoblac
        FROM gest_outsourcing a,
             per_personas p,
             (SELECT sperson,
                     cregfiscal
                FROM per_regimenfiscal
               WHERE (sperson, fefecto) IN
                     (SELECT sperson,
                             MAX(fefecto)
                        FROM per_regimenfiscal
                       GROUP BY sperson)) r
       WHERE a.coutsour = pcoutsour
         AND p.sperson = a.sperson
         AND p.sperson = r.sperson(+);
      --
      SELECT d.porcent
        INTO vvalor
        FROM tipos_indicadores     t,
             tipos_indicadores_det d,
             codpostal             c
       WHERE t.carea = 2
         AND t.ctipreg = 2
         AND t.cimpret = 4
         AND t.ctipind = d.ctipind
         AND d.cpostal = c.cpostal
         AND c.cprovin = vcprovin
         AND c.cpoblac = vcpoblac;
      --
      RETURN vvalor / 1000;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         RETURN 0;
         --
   END f_reteica_indicador;

   --
   /*************************************************************************
      FUNCTION f_get_reteniva

      param in pcoutsour    : C¿digo OUTSOURCING
      param in pfecha       : Fecha
      return                : NUMBER
   *************************************************************************/
   --
   FUNCTION f_get_reteniva(pcoutsour IN NUMBER,
                           pfecha    IN DATE) RETURN NUMBER IS
      --
      ppretenc NUMBER;
      --
   BEGIN
      --
      SELECT pretenc
        INTO ppretenc
        FROM retenciones      ret,
             gest_outsourcing g
       WHERE g.coutsour = pcoutsour
         AND ret.cretenc = g.cretenc
         AND TRUNC(pfecha) >= TRUNC(finivig)
         AND TRUNC(pfecha) < TRUNC(NVL(ffinvig, pfecha + 1));
      --
      RETURN ppretenc / 1000;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         RETURN NULL;
         --
   END f_get_reteniva;

   --
   /*************************************************************************
      FUNCTION f_get_tipiva

      param in pcoutsour    : C¿digo OUTSOURCING
      param in pfecha       : Fecha
      return                : NUMBER
   *************************************************************************/
   --
   FUNCTION f_get_tipiva(pcoutsour IN NUMBER,
                         pfecha    IN DATE) RETURN NUMBER IS
      --
      pptipiva NUMBER;
      --
   BEGIN
      SELECT ptipiva
        INTO pptipiva
        FROM tipoiva          t,
             gest_outsourcing g
       WHERE g.coutsour = pcoutsour
         AND t.ctipiva = g.ctipiva
         AND TRUNC(pfecha) >= TRUNC(finivig)
         AND TRUNC(pfecha) < TRUNC(NVL(ffinvig, pfecha + 1));
      --
      RETURN pptipiva / 100;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         RETURN NULL;
         --
   END f_get_tipiva;

   --
   /*************************************************************************
      FUNCTION f_procesa_carga

      param in p_nombre     : Nombre del archivo
      param in p_path       : Patch
      param in p_cproces    : C¿digo del proceso
      param in out psproces : Secuencia de proceso
      return                : NUMBER
   *************************************************************************/
   --
   FUNCTION f_procesa_carga(psproces IN NUMBER) RETURN NUMBER IS
      --
      v_texto   VARCHAR2(200);
      vnum_err  NUMBER;
      v_count   NUMBER;
      v_recibos NUMBER;
      v_porce   NUMBER;
      v_minim   NUMBER;
      v_maxim   NUMBER;
      v_valor   NUMBER;
      v_tarif   NUMBER;
      --
      v_iva    NUMBER;
      v_retiva NUMBER;
      v_retfte NUMBER;
      v_ica    NUMBER;
      --
      v_r_gcab gest_liquidacab %ROWTYPE;
      v_r_lcab gest_liquidalin %ROWTYPE;
      --
   BEGIN
      --
      v_r_gcab.sliquida := psproces;
      --
      --Recorre las p¿lizas a tratar
      FOR c_dat IN (SELECT i.poliza,
                           g.coutsour,
                           ROWNUM
                      FROM int_carga_outsourcing i,
                           gest_outsourcing      g
                     WHERE i.proveedor = g.coutsour)
      LOOP
         --
         SELECT COUNT(*)
           INTO v_count
           FROM seguros
          WHERE npoliza = c_dat.poliza;
         --
         IF v_count > 0
         THEN
            --
            v_r_gcab.coutsour := c_dat.coutsour;
            v_r_gcab.cestado  := 0;
            v_r_gcab.fliquida := f_sysdate;
            v_r_gcab.importe  := 0;
            v_r_gcab.iva      := 0;
            v_r_gcab.reteiva  := 0;
            v_r_gcab.ica      := 0;
            v_r_gcab.rtefte   := 0;
            v_r_gcab.totalimp := 0;
            v_r_gcab.falta    := f_sysdate;
            v_r_gcab.cuser    := f_user;
            --
            BEGIN
               --
               INSERT INTO gest_liquidacab VALUES v_r_gcab;
               --
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  --
                  SELECT *
                    INTO v_r_gcab
                    FROM gest_liquidacab
                   WHERE coutsour = c_dat.coutsour
                     AND sliquida = psproces;
                  --
            END;
            --
            v_recibos := NULL;
            --
            FOR c_rec IN c_recibos_cobrados(c_dat.poliza)
            LOOP
               --
               v_recibos := 4;
               --
               --Obtiene el porcentaje
               v_porce := pac_subtablas.f_vsubtabla(p_in_nsesion   => -1,
                                                    p_in_csubtabla => 8000046,
                                                    p_in_cquery    => 224,
                                                    p_in_cval      => 1,
                                                    p_in_ccla1     => c_rec.itotalr,
                                                    p_in_ccla2     => c_rec.dias_cartera,
                                                    p_in_ccla3     => c_rec.dias_cartera);
               --
               --Obtiene el valor m¿nimo
               v_minim := pac_subtablas.f_vsubtabla(p_in_nsesion   => -1,
                                                    p_in_csubtabla => 8000046,
                                                    p_in_cquery    => 224,
                                                    p_in_cval      => 2,
                                                    p_in_ccla1     => c_rec.itotalr,
                                                    p_in_ccla2     => c_rec.dias_cartera,
                                                    p_in_ccla3     => c_rec.dias_cartera);
               --
               --Obtiene el valor m¿ximo
               v_maxim := pac_subtablas.f_vsubtabla(p_in_nsesion   => -1,
                                                    p_in_csubtabla => 8000046,
                                                    p_in_cquery    => 224,
                                                    p_in_cval      => 3,
                                                    p_in_ccla1     => c_rec.itotalr,
                                                    p_in_ccla2     => c_rec.dias_cartera,
                                                    p_in_ccla3     => c_rec.dias_cartera);
               --
               --Calcula tarifa por recibo
               v_valor := (c_rec.itotalr * NVL(v_porce, 0)) / 100;
               --
               IF NVL(v_valor, 0) < NVL(v_minim, 0)
               THEN
                  --
                  v_tarif := NVL(v_minim, 0);
                  --
               ELSIF NVL(v_valor, 0) < NVL(v_maxim, 0)
               THEN
                  --
                  v_tarif := NVL(v_maxim, 0);
                  --
               ELSE
                  --
                  v_tarif := NVL(v_valor, 0);
                  --
               END IF;
               --
               v_tarif := NVL(v_tarif, 0);
               --
               --C¿lculo de conceptos
               v_iva    := NVL(f_get_tipiva(c_dat.coutsour, f_sysdate), 0);
               v_retiva := NVL(f_get_reteniva(c_dat.coutsour, f_sysdate), 0);
               v_ica    := NVL(f_reteica_indicador(c_dat.coutsour), 0);
               v_retfte := NVL(f_retefuente(c_dat.coutsour), 0);
               --
               v_r_lcab.sliquida := v_r_gcab.sliquida;
               v_r_lcab.coutsour := v_r_gcab.coutsour;
               v_r_lcab.nrecibo  := c_rec.nrecibo;
               v_r_lcab.importe  := v_tarif;
               v_r_lcab.iva      := v_tarif * v_iva;
               v_r_lcab.reteiva  := v_tarif * v_retiva;
               v_r_lcab.ica      := v_tarif * v_ica;
               v_r_lcab.rtefte   := v_tarif * v_retfte;
               --
               v_r_lcab.totalimp := (v_r_lcab.importe + v_r_lcab.iva) -
                                    (v_r_lcab.reteiva + v_r_lcab.ica +
                                    v_r_lcab.rtefte);
               v_r_lcab.falta    := f_sysdate;
               v_r_lcab.cuser    := f_user;
               --
               INSERT INTO gest_liquidalin VALUES v_r_lcab;
               --
               --Totaliza
               v_r_gcab.importe  := NVL(v_r_gcab.importe, 0) +
                                    NVL(v_r_lcab.importe, 0);
               v_r_gcab.iva      := NVL(v_r_gcab.iva, 0) +
                                    NVL(v_r_lcab.iva, 0);
               v_r_gcab.reteiva  := NVL(v_r_gcab.reteiva, 0) +
                                    NVL(v_r_lcab.reteiva, 0);
               v_r_gcab.ica      := NVL(v_r_gcab.ica, 0) +
                                    NVL(v_r_lcab.ica, 0);
               v_r_gcab.rtefte   := NVL(v_r_gcab.rtefte, 0) +
                                    NVL(v_r_lcab.rtefte, 0);
               v_r_gcab.totalimp := NVL(v_r_gcab.totalimp, 0) +
                                    NVL(v_r_lcab.totalimp, 0);
               --
            END LOOP;
            --
            --Actualiza cabecera
            UPDATE gest_liquidacab
               SET importe  = v_r_gcab.importe,
                   iva      = v_r_gcab.iva,
                   reteiva  = v_r_gcab.reteiva,
                   ica      = v_r_gcab.ica,
                   rtefte   = v_r_gcab.rtefte,
                   totalimp = v_r_gcab.totalimp
             WHERE sliquida = v_r_gcab.sliquida
               AND coutsour = v_r_gcab.coutsour;
            --
            v_recibos := NVL(v_recibos, 2);
            v_texto   := 'ALTA(OK)';
            --
            IF v_recibos = 2
            THEN
               --
               v_texto := 'ALTA(KO) - P¿liza no tiene recibos cobrados: ' ||
                          c_dat.poliza;
               --
            END IF;
            --
            vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                    pnlinea    => c_dat.rownum,
                                                                    pctipo     => 0,
                                                                    pidint     => c_dat.rownum,
                                                                    pidext     => NULL,
                                                                    pcestado   => v_recibos,
                                                                    pcvalidado => 0,
                                                                    psseguro   => NULL,
                                                                    pidexterno => v_texto,
                                                                    pncarga    => NULL,
                                                                    pnsinies   => NULL,
                                                                    pntramit   => NULL,
                                                                    psperson   => NULL,
                                                                    pnrecibo   => NULL);
            --
            --
         ELSE
            --No existe p¿liza
            vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                    pnlinea    => c_dat.rownum,
                                                                    pctipo     => 0,
                                                                    pidint     => c_dat.rownum,
                                                                    pidext     => NULL,
                                                                    pcestado   => 2,
                                                                    pcvalidado => 0,
                                                                    psseguro   => NULL,
                                                                    pidexterno => 'ALTA(KO) - P¿liza no Existe: ' ||
                                                                                  c_dat.poliza,
                                                                    pncarga    => NULL,
                                                                    pnsinies   => NULL,
                                                                    pntramit   => NULL,
                                                                    psperson   => NULL,
                                                                    pnrecibo   => NULL);
            --
         END IF;
         --
      END LOOP;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN OTHERS THEN
         --
         p_tab_error(pferror   => f_sysdate,
                     pcusuari  => f_user,
                     ptobjeto  => 'PAC_OUTSOURCING_CONF.f_procesa_carga',
                     pntraza   => 1,
                     ptdescrip => dbms_utility.format_error_backtrace,
                     pterror   => SQLERRM);
         --
         RETURN 1;
         --
   END f_procesa_carga;

   /*************************************************************************
      FUNCTION f_ejecutar_carga

      param in p_nombre     : Nombre del archivo
      param in p_path       : Patch
      param in p_cproces    : C¿digo del proceso
      param in out psproces : Secuencia de proceso
      return                : NUMBER
   *************************************************************************/
   --
   FUNCTION f_ejecutar_carga(p_nombre  IN VARCHAR2,
                             p_path    IN VARCHAR2,
                             p_cproces IN NUMBER,
                             psproces  IN OUT NUMBER) RETURN NUMBER IS
      --
      vnnumlin NUMBER;
      vnum_err NUMBER;
      vdes_err VARCHAR2(2000);
      --
   BEGIN
      --
      IF p_nombre IS NULL OR
         p_path IS NULL OR
         p_cproces IS NULL
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      psproces := sproces.nextval;
      --
      --Inicio del proceso
      vnum_err := f_procesini(pcusuari => f_user,
                              pcempres => f_empres,
                              pcproces => p_cproces,
                              ptproces => p_nombre,
                              psproces => psproces);
      --
      IF vnum_err != 0
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      --Inicio de la carga del fichero
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces  => psproces,
                                                                 ptfichero => p_nombre,
                                                                 pfini     => f_sysdate,
                                                                 pffin     => NULL,
                                                                 pcestado  => 3,
                                                                 pcproceso => p_cproces,
                                                                 pcerror   => NULL,
                                                                 pterror   => NULL,
                                                                 pcbloqueo => NULL);
      --
      IF vnum_err != 0
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      --
      EXECUTE IMMEDIATE 'ALTER TABLE INT_CARGA_OUTSOURCING ACCESS PARAMETERS (records delimited by 0x''0A''
                         logfile ' || chr(39) ||
                        p_nombre || '.log' || chr(39) || '
                         badfile ' || chr(39) ||
                        p_nombre || '.bad' || chr(39) || '
                         discardfile ' || chr(39) ||
                        p_nombre || '.dis' || chr(39) || '
                         fields terminated by '','' LRTRIM
                         MISSING FIELD VALUES ARE NULL
                         REJECT ROWS WITH ALL NULL FIELDS
                         (  SUCURSAL       ,
								    PROVEEDOR      ,
								    NIT_CLIENTE    ,
									 NOMBRE_CLIENTE ,
									 POLIZA         ,
									 CERTIF         ,
									 FGESTI         ,
									 CODGES         ,
									 USU_PROV       ,
									 DIRECCION      ,
									 TELEFONO       ,
									 VALOR_POLIZA   ,
									 VIGENCIA_POL   ,
									 NOM_USER       ,
									 CAGENTE        ,
									 CONCEPTO
                        ))';
      --
      EXECUTE IMMEDIATE 'ALTER TABLE INT_CARGA_OUTSOURCING LOCATION (' ||
                        p_path || ':''' || p_nombre || ''')';
      --
      --Procesa la carga de datos
      vnum_err := f_procesa_carga(psproces);
      --
      IF vnum_err != 0
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      --Fin del proceso
      vnum_err := f_procesfin(psproces => psproces, pnerror => 0);
      --
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces  => psproces,
                                                                 ptfichero => p_nombre,
                                                                 pfini     => f_sysdate,
                                                                 pffin     => f_sysdate,
                                                                 pcestado  => 4,
                                                                 pcproceso => p_cproces,
                                                                 pcerror   => NULL,
                                                                 pterror   => NULL,
                                                                 pcbloqueo => NULL);
      --
      COMMIT;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         --
         ROLLBACK;
         --
         vdes_err := f_axis_literales(103187, f_idiomauser);
         vdes_err := vdes_err || ':' || p_nombre || ' : ' || SQLERRM;
         --
         vnum_err := f_proceslin(psproces    => psproces,
                                 par_tprolin => vdes_err,
                                 pnpronum    => 1,
                                 pnprolin    => vnnumlin);
         --
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces  => psproces,
                                                                    ptfichero => p_nombre,
                                                                    pfini     => f_sysdate,
                                                                    pffin     => NULL,
                                                                    pcestado  => 1,
                                                                    pcproceso => p_cproces,
                                                                    pcerror   => 151541,
                                                                    pterror   => SQLERRM,
                                                                    pcbloqueo => NULL);
         --
         RETURN 1;
         --
      WHEN OTHERS THEN
         --
         ROLLBACK;
         --
         vdes_err := f_axis_literales(103187, f_idiomauser);
         vdes_err := vdes_err || ':' || p_nombre || ' : ' || SQLERRM;
         --
         vnum_err := f_proceslin(psproces    => psproces,
                                 par_tprolin => vdes_err,
                                 pnpronum    => 1,
                                 pnprolin    => vnnumlin);
         --
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces  => psproces,
                                                                    ptfichero => p_nombre,
                                                                    pfini     => f_sysdate,
                                                                    pffin     => NULL,
                                                                    pcestado  => 1,
                                                                    pcproceso => p_cproces,
                                                                    pcerror   => 151541,
                                                                    pterror   => SQLERRM,
                                                                    pcbloqueo => NULL);
         --
         RETURN 1;
         --
   END f_ejecutar_carga;
   /*************************************************************************
      FUNCTION f_carga_gescar
      param in p_nombre     : Nombre del archivo
      param in p_path       : Patch
      param in p_cproces    : C¿digo del proceso
      param in out psproces : Secuencia de proceso
      return                : NUMBER
   *************************************************************************/
   FUNCTION f_carga_gescar(p_nombre  IN VARCHAR2,
                           p_path    IN VARCHAR2,
                           p_cproces IN NUMBER,
                           psproces  IN OUT NUMBER) RETURN NUMBER IS
      --
      vnnumlin    NUMBER;
      vnum_err    NUMBER;
      v_nrecibo   NUMBER;
      v_cegescar  VARCHAR2(2);
      vdes_err    VARCHAR2(2000);
      v_line      VARCHAR2(32767);
      v_sep       VARCHAR2(1) := ';';
      v_param     VARCHAR2(2000):= 'p_nombre-'||p_nombre||' p_path-'||p_path||' p_cproces-'||p_cproces||' psproces-'||psproces;
      v_numlineaf NUMBER := 1;
      v_file      utl_file.file_type;
      vduplicado   NUMBER;--IAXIS-4514 Mensaje por duplicidad en Archivo outsourcing
      --
   BEGIN
      --
      IF p_nombre IS NULL OR
         p_path IS NULL OR
         p_cproces IS NULL
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      psproces := sproces.nextval;
      --
      --Inicio del proceso
      vnum_err := f_procesini(pcusuari => f_user,
                              pcempres => f_empres,
                              pcproces => p_cproces,
                              ptproces => p_nombre,
                              psproces => psproces);                              
      --
      IF vnum_err != 0
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --
      --Inicio de la carga del fichero

      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces  => psproces,
                                                                 ptfichero => p_nombre,
                                                                 pfini     => f_sysdate,
                                                                 pffin     => NULL,
                                                                 pcestado  => 3,
                                                                 pcproceso => p_cproces,
                                                                 pcerror   => NULL,
                                                                 pterror   => NULL,
                                                                 pcbloqueo => NULL);


      --
      IF vnum_err != 0
      THEN
         --
         RAISE e_param_error;
         --
      END IF;
      --     
      v_file := utl_file.fopen(p_path, p_nombre, 'R', 256);            
      --
      LOOP
         EXIT WHEN v_numlineaf = -1;
         --
         BEGIN          
            --
            v_numlineaf := v_numlineaf + 1;			
			utl_file.get_line(v_file, v_line, 32767);			
            --
            v_nrecibo := pac_util.splitt(v_line, 1, v_sep);
            --				
            v_cegescar := SUBSTR(pac_util.splitt(v_line, 2, v_sep), 1, 2);            
            --SGM INI IAXIS-4514 Mensaje por duplicidad en Archivo outsourcing
            BEGIN   
               SELECT count(*)
                 INTO vduplicado
                 FROM int_carga_ctrl_linea 
                WHERE sproces = psproces
			      AND cestado = 4		
                  AND to_number(REPLACE(idext,'Recibo actualizado: ',''))= v_nrecibo;
            EXCEPTION 
               WHEN NO_DATA_FOUND THEN                
               vduplicado := 0;
            END;
            
            --
            IF vduplicado = 0 THEN             
                UPDATE recibos
                   SET cgescar = DECODE(v_cegescar, 'SI', 2, 1),
                       fmarcagest = DECODE(v_cegescar, 'SI', f_sysdate, null)--SGM IAXIS 5241 Marcacion con fecha gestion outsourcing
                 WHERE nrecibo = v_nrecibo;
                --
                vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                        pnlinea    => v_numlineaf - 1,
                                                                        pctipo     => 2,
                                                                        pidint     => v_numlineaf - 1,
                                                                        pidext     => NULL,
                                                                        pcestado   => 4,
                                                                        pcvalidado => 0,
                                                                        psseguro   => NULL,
                                                                        pidexterno => 'Recibo actualizado: ' ||
                                                                                      v_nrecibo,
                                                                        pncarga    => NULL,
                                                                        pnsinies   => NULL,
                                                                        pntramit   => NULL,
                                                                        psperson   => NULL,
                                                                        pnrecibo   => v_nrecibo);
             ELSE                 
                vnum_err := pac_gestion_procesos.f_set_carga_ctrl_linea(psproces   => psproces,
                                                                        pnlinea    => v_numlineaf - 1,
                                                                        pctipo     => 2,
                                                                        pidint     => v_numlineaf - 1,
                                                                        pidext     => NULL,
                                                                        pcestado   => 5,
                                                                        pcvalidado => 0,
                                                                        psseguro   => NULL,
                                                                        pidexterno => 'Recibo duplicado: ' ||
                                                                                      v_nrecibo,
                                                                        pncarga    => NULL,
                                                                        pnsinies   => NULL,
                                                                        pntramit   => NULL,
                                                                        psperson   => NULL,
                                                                        pnrecibo   => v_nrecibo);
                                                                        
                 vduplicado := 0;                                                       
             END IF;
             --SGM FIN IAXIS-4514 Mensaje por duplicidad en Archivo outsourcing                                                       
            --
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               --
			   v_numlineaf := -1;
               --
         END;
         --
      END LOOP;
      --
      utl_file.fclose(v_file);

      --
      --Fin del proceso
      vnum_err := f_procesfin(psproces => psproces, pnerror => 0);     
      --
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces  => psproces,
                                                                 ptfichero => p_nombre,
                                                                 pfini     => f_sysdate,
                                                                 pffin     => f_sysdate,
                                                                 pcestado  => 4,
                                                                 pcproceso => p_cproces,
                                                                 pcerror   => NULL,
                                                                 pterror   => NULL,
                                                                 pcbloqueo => NULL);
      --
      COMMIT;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         --
         ROLLBACK;
         --
         utl_file.fclose(v_file);
         --
         vdes_err := f_axis_literales(103187, f_idiomauser);
         vdes_err := vdes_err || ':' || p_nombre || ' : ' || SQLERRM;
         --
         vnum_err := f_proceslin(psproces    => psproces,
                                 par_tprolin => vdes_err,
                                 pnpronum    => 1,
                                 pnprolin    => vnnumlin);

         --
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces  => psproces,
                                                                    ptfichero => p_nombre,
                                                                    pfini     => f_sysdate,
                                                                    pffin     => NULL,
                                                                    pcestado  => 1,
                                                                    pcproceso => p_cproces,
                                                                    pcerror   => 151541,
                                                                    pterror   => SQLERRM,
                                                                    pcbloqueo => NULL);
         --
         RETURN 1;
         --
      WHEN OTHERS THEN
         --         
         ROLLBACK;
         --
         utl_file.fclose(v_file);
         --
         vdes_err := f_axis_literales(103187, f_idiomauser);
         vdes_err := vdes_err || ':' || p_nombre || ' : ' || SQLERRM;

         --
         vnum_err := f_proceslin(psproces    => psproces,
                                 par_tprolin => vdes_err,
                                 pnpronum    => 1,
                                 pnprolin    => vnnumlin);
         --
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces  => psproces,
                                                                    ptfichero => p_nombre,
                                                                    pfini     => f_sysdate,
                                                                    pffin     => NULL,
                                                                    pcestado  => 1,
                                                                    pcproceso => p_cproces,
                                                                    pcerror   => 151541,
                                                                    pterror   => SQLERRM,
                                                                    pcbloqueo => NULL);
         --
         RETURN 1;
         --
   END f_carga_gescar;
   --
END pac_outsourcing_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_OUTSOURCING_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_OUTSOURCING_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_OUTSOURCING_CONF" TO "PROGRAMADORESCSI";
