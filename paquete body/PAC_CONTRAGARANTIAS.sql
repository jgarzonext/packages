create or replace PACKAGE BODY PAC_CONTRAGARANTIAS IS
   /******************************************************************************
      NOMBRE:    pac_contragarantias
      PROPSITO: Funciones para contragarantias

      REVISIONES:
      Ver        Fecha        Autor             Descripcin
      ---------  ----------  ---------------  ------------------------------------
      1.0        02/03/2016  JAE              1. Creacinn del objeto.
      2.0        14/02/2019  ACL              2. Se modifica la funcion f_getrelacion_sperson.
      3.0        20/02/2019  ACL              3. Se modifica lista en las funciones f_get_contragaran_cab y f_getrelacion_sperson
      4.0        25/02/2019  ACL              4. TCS_826: Se agrega parmetros a la funcin f_ins_contragaran_det.
      5.0        01/03/2019  ACL              3. TCS_823: Se modifica la consulta en la funcin f_get_contragaran_mov.
      6.0        07/03/2019  KRK               4. IAXIS_2110: TCS_825: VizualizaciÃ³n de valor asegurado en la ContragarantÃ­a
	  7.0        14/03/2019  ACL              7. TCS_309: Se agrega parametros a la funcion f_ins_contragaran_det
	  8.0        18/03/2019  ACL              8. TCS_309: Se agrega parametros de texto a la funcion f_ins_contragaran_det
   ******************************************************************************/

   /*************************************************************************
      FUNCTION f_ins_contragaran_doc

      param in pscontgar : Identificador contragaranta
      param in nmovimi   : Nmero de movimiento
      param in iddocgdx  : Id del documento en Gedox
      param in ctipo     : Tipo documento
      param in fcaduci   : Fecha de caducidad
      param in falta     : Fecha de alta
      param in tobserv   : Observaciones
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_edit_contragaran_doc(pscontgar IN NUMBER,
                                   pnmovimi  IN NUMBER,
                                   piddocgdx IN NUMBER,
                                   pctipo    IN NUMBER,
                                   ptobserv  IN VARCHAR2,
                                   pfcaduci  IN DATE,
                                   mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_edit_contragaran_doc';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' pnmovimi: ' ||
                                pnmovimi || ' piddocgdx: ' || piddocgdx ||
                                ' pctipo: ' || pctipo || ' ptobserv: ' ||
                                ptobserv || ' pfcaduci: ' || pfcaduci;
      --
   BEGIN
      --
      UPDATE ctgar_doc
         SET ctipo = pctipo, tobserv = ptobserv, fcaduci = pfcaduci
       WHERE pscontgar = pscontgar
         AND pnmovimi = pnmovimi
         AND piddocgdx = piddocgdx;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_edit_contragaran_doc;

   /*************************************************************************
      FUNCTION f_ins_contragaran_doc

      param in pscontgar : Identificador contragaranta
      param in nmovimi   : Nmero de movimiento
      param in iddocgdx  : Id del documento en Gedox
      param in ctipo     : Tipo documento
      param in fcaduci   : Fecha de caducidad
      param in falta     : Fecha de alta
      param in tobserv   : Observaciones
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_doc(pscontgar IN NUMBER,
                                  pnmovimi  IN NUMBER,
                                  piddocgdx IN NUMBER,
                                  pctipo    IN NUMBER,
                                  ptobserv  IN VARCHAR2,
                                  pfcaduci  IN DATE,
                                  pfalta    IN DATE,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_ins_contragaran_doc';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' pnmovimi: ' ||
                                pnmovimi || ' piddocgdx: ' || piddocgdx ||
                                ' pctipo: ' || pctipo || ' ptobserv: ' ||
                                ptobserv || ' pfcaduci: ' || pfcaduci ||
                                ' pfalta: ' || pfalta;
      --
   BEGIN
      --
      INSERT INTO ctgar_doc
         (scontgar, nmovimi, iddocgdx, ctipo, tobserv, fcaduci, falta)
      VALUES
         (pscontgar, pnmovimi, piddocgdx, pctipo, ptobserv, pfcaduci,
          NVL(pfalta, f_sysdate));
      --
      COMMIT;
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_ins_contragaran_doc;

   /*************************************************************************
      FUNCTION f_ins_contragaran_pol

      param in pscontgar : Identificador contragaranta
      param in psseguro  : Identificador seguro
      param in pnmovimi  : Nmero de movimiento
      param in ptablas   : Tablas Reales/Estudio
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_pol(pscontgar IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pnmovimi  IN NUMBER,
                                  ptablas   IN VARCHAR2,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_ins_contragaran_pol';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' psseguro: ' ||
                                psseguro || ' pnmovimi: ' || pnmovimi ||
                                ' ptablas: ' || ptablas;
      --
      v_valor   NUMBER; -- KRK -- 7/3/2019
   BEGIN
      --
      IF ptablas = 'EST'
      THEN
         --
         BEGIN
            --
            INSERT INTO estctgar_seguro
               (scontgar, sseguro, nmovimi)
            VALUES
               (pscontgar, psseguro, pnmovimi);
            --
         EXCEPTION
            WHEN OTHERS THEN
               --
               UPDATE estctgar_seguro
                  SET sseguro = psseguro, nmovimi = pnmovimi
                WHERE scontgar = pscontgar;
               --
         END;
         --
      ELSE
         --
         BEGIN
            --
            INSERT INTO ctgar_seguro
               (scontgar, sseguro, nmovimi)
            VALUES
               (pscontgar, psseguro, pnmovimi);
            --
         EXCEPTION
            WHEN OTHERS THEN
               --
               UPDATE ctgar_seguro
                  SET sseguro = psseguro, nmovimi = pnmovimi
                WHERE scontgar = pscontgar;
               --
         END;
         --
      END IF;
      -- Inicio KRK -- 7/3/2019
      BEGIN
         SELECT SUM (icapital)
           INTO v_valor
           FROM garanseg a
          WHERE a.sseguro = psseguro
            AND a.nmovimi =
                   (SELECT MAX (b.nmovimi)
                      FROM garanseg b
                     WHERE b.sseguro = a.sseguro
                       AND b.nriesgo = a.nriesgo
                      );
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_valor := 0;
      END;

      UPDATE ctgar_contragarantia
         SET ivalor = v_valor
       WHERE scontgar = pscontgar AND nmovimi = pnmovimi and cestado = 2;
      -- Fin KRK -- 7/3/2019
      COMMIT;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_ins_contragaran_pol;

   /*************************************************************************
      FUNCTION f_del_contragaran_pol

      param in pscontgar : Identificador contragaranta
      param in psseguro  : Identificador seguro
      param in pnmovimi  : Nmero de movimiento
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_del_contragaran_pol(pscontgar IN NUMBER,
                                  psseguro  IN NUMBER,
                                  pnmovimi  IN NUMBER,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_del_contragaran_pol';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' psseguro: ' ||
                                psseguro || ' pnmovimi: ' || pnmovimi;
      --
   BEGIN
      --
      DELETE estctgar_seguro
       WHERE scontgar = pscontgar
         AND sseguro = psseguro
         AND nmovimi = pnmovimi;
      --
      COMMIT;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_del_contragaran_pol;

   /*************************************************************************
      FUNCTION f_ins_contragaran_codeu

      param in pscontgar : Identificador contragaranta
      param in psperson  : Identificador psperson
      param in pnmovimi  : Nmero de movimiento
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_del_contragaran_codeu(pscontgar IN NUMBER,
                                    psperson  IN NUMBER,
                                    pnmovimi  IN NUMBER,
                                    mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_del_contragaran_codeu';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' psperson: ' ||
                                psperson || ' pnmovimi: ' || pnmovimi;
      --
   BEGIN
      --
      DELETE ctgar_codeudor
       WHERE scontgar = pscontgar
         AND nmovimi = pnmovimi
         AND sperson = psperson;
      --
      COMMIT;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_del_contragaran_codeu;

   /*************************************************************************
      FUNCTION f_ins_contragaran_codeu

      param in pscontgar : Identificador contragaranta
      param in psperson  : Identificador psperson
      param in pnmovimi  : Nmero de movimiento
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_codeu(pscontgar IN NUMBER,
                                    psperson  IN NUMBER,
                                    pnmovimi  IN NUMBER,
                                    mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_ins_contragaran_codeu';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' psperson: ' ||
                                psperson || ' pnmovimi: ' || pnmovimi;
      --
   BEGIN
      --
      INSERT INTO ctgar_codeudor
         (scontgar, nmovimi, sperson)
      VALUES
         (pscontgar, pnmovimi,
          NVL(pac_persona.f_sperson_spereal(psperson), psperson));
      --
      COMMIT;
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_ins_contragaran_codeu;

   /*************************************************************************
      FUNCTION f_ins_contragaran_inm

      param in pscontgar     : Identificador contragaranta
      param in psinmueble    : Identificador nico / Secuencia del inmueble
      param in pnnumescr     : Numero de la escritura publica
      param in pfescritura   : Fecha de la escritura
      param in ptdescripcion : Descripcin general
      param in ptdireccion   : Direccin del inmueble
      param in pcpais        : Pais
      param in pcprovin      : Codigo de Provincia
      param in pcpoblac      : Municipio
      param in pfcertlib     : Certificado libertad
      param in mensajes      : t_iax_mensajes
      return                 : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_inm(pscontgar     IN NUMBER,
                                  pnnumescr     IN NUMBER,
                                  pfescritura   IN DATE,
                                  ptdescripcion IN VARCHAR2,
                                  ptdireccion   IN VARCHAR2,
                                  pcpais        IN NUMBER,
                                  pcprovin      IN NUMBER,
                                  pcpoblac      IN NUMBER,
                                  pfcertlib     IN DATE,
                                  mensajes      IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_ins_contragaran_inm';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar ||
                                ' pnnumescr: ' || pnnumescr ||
                                ' pfescritura: ' || pfescritura ||
                                ' ptdescripcion: ' || ptdireccion ||
                                ' ptdireccion: ' || ptdireccion ||
                                ' pcpais: ' || pcpais || ' pcprovin: ' ||
                                pcprovin || ' pcpoblac: ' || pcpoblac ||
                                ' pfcertlib: ' || pfcertlib;
      --
      vsinmueble NUMBER := sinmueble.nextval;
      --
   BEGIN
      --
      INSERT INTO ctgar_inmueble
         (sinmueble, nnumescr, fescritura, tdescripcion, tdireccion, cpais,
          cprovin, cpoblac, fcertlib)
      VALUES
         (vsinmueble, pnnumescr, pfescritura, ptdescripcion, ptdireccion,
          pcpais, pcprovin, pcpoblac, pfcertlib);
      --
      --Si asocia contragaranta se actualiza el ltimo movimiento
      IF pscontgar IS NOT NULL
      THEN
         --
         UPDATE ctgar_det c
            SET sinmueble = vsinmueble
          WHERE scontgar = pscontgar
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM ctgar_det
                            WHERE scontgar = c.scontgar);
         --
      END IF;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_ins_contragaran_inm;

   /*************************************************************************
      FUNCTION f_ins_contragaran_vh

      param in pscontgar : Identificador contragaranta
      param in psvehiculo: Identificador vehculo
      param in pcpoblac  : Pas
      param in pcpoblac  : Provincia
      param in pcpoblac  : Poblacin
      param in pcmarca   : Marca
      param in pctipo    : Tipo
      param in pnmotor   : Numero de motor
      param in pnplaca   : Numero de placa
      param in pncolor   : Color
      param in pnserie   : Serie
      param in pcasegura : Asegura
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_vh(pscontgar IN NUMBER,
                                 pcpais    IN NUMBER,
                                 pcprovin  NUMBER,
                                 pcpoblac  IN NUMBER,
                                 pcmarca   IN NUMBER,
                                 pctipo    IN NUMBER,
                                 pnmotor   IN VARCHAR2,
                                 pnplaca   IN VARCHAR2,
                                 pncolor   IN NUMBER,
                                 pnserie   IN NUMBER,
                                 pcasegura IN NUMBER,
								 pmodelo   IN DATE, 			-- IAXIS-3053 BARTOLO HERRERA - 08/03/2019
                                 mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_ins_contragaran_vh';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' pcpoblac: ' ||
                                pcpoblac || ' pcmarca: ' || pcmarca ||
                                ' pctipo: ' || pctipo || ' pcmarca: ' ||
                                pcmarca || ' pnmotor: ' || pnmotor ||
                                ' pnplaca: ' || pnplaca || ' pncolor: ' ||
                                pncolor || ' pnserie: ' || pnserie ||
                                ' pcasegura: ' || pcasegura;
      --
      vsvehiculo NUMBER := svehiculo.nextval;
      --
   BEGIN
      --
      INSERT INTO ctgar_vehiculo
         (svehiculo, cpais, cprovin, cpoblac, cmarca, ctipo, nmotor, nplaca,
          ncolor, nserie, casegura, modelo)-- IAXIS-3053 BARTOLO HERRERA - 08/03/2019
      VALUES
         (vsvehiculo, pcpais, pcprovin, pcpoblac, pcmarca, pctipo, pnmotor,
          pnplaca, pncolor, pnserie, pcasegura, pmodelo);-- IAXIS-3053 BARTOLO HERRERA - 08/03/2019
      --
      --Si asocia contragaranta se actualiza el ltimo movimiento
      IF pscontgar IS NOT NULL
      THEN
         --
         UPDATE ctgar_det c
            SET svehiculo = vsvehiculo
          WHERE scontgar = pscontgar
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM ctgar_det
                            WHERE scontgar = c.scontgar);
         --
      END IF;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_ins_contragaran_vh;

   /*************************************************************************
      FUNCTION f_ins_contragaran_per

      param in pscontgar : Identificador contragaranta
      param in psperson  : Identificador psperson
      param in ptablas   : Tablas Reales/Estudio
      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_per(pscontgar IN NUMBER,
                                  psperson  IN NUMBER,
                                  ptablas   IN VARCHAR2,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_ins_contragaran_per';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' psperson: ' ||
                                psperson || ' ptablas: ' || ptablas;
      --
   BEGIN
      --
      IF ptablas = 'EST'
      THEN
         --
         BEGIN
            --
            vpasexec := 2;
            INSERT INTO estper_contragarantia VALUES (pscontgar, psperson);
            --
         EXCEPTION
            WHEN OTHERS THEN
               --
               UPDATE estper_contragarantia
                  SET sperson = psperson
                WHERE scontgar = pscontgar;
               --
         END;
         --
      ELSE
         --
         BEGIN
            --
            vpasexec := 3;
            INSERT INTO per_contragarantia
            VALUES
               (pscontgar,
                NVL(pac_persona.f_sperson_spereal(psperson), psperson));
            --
         EXCEPTION
            WHEN dup_val_on_index THEN
               --
               UPDATE per_contragarantia
                  SET sperson = NVL(pac_persona.f_sperson_spereal(psperson),
                                    psperson)
                WHERE scontgar = pscontgar;
               --
         END;

         --
      END IF;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_ins_contragaran_per;

   /*************************************************************************
      FUNCTION f_ins_contragaran_det

      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_det(pscontgar  IN NUMBER,
                                  pnmovimi   IN NUMBER,
                                  pcpais     IN NUMBER,
                                  pfexpedic  IN DATE,
                                  pcbanco    IN NUMBER,
                                  psperfide  IN NUMBER,
                                  ptsucursal IN VARCHAR2,
                                  piinteres  IN NUMBER,
                                  pfvencimi  IN DATE,
                                  pfvencimi1 IN DATE,
                                  pfvencimi2 IN DATE,
                                  pnplazo    IN NUMBER,
                                  piasegura  IN NUMBER,
                                  piintcap   IN NUMBER,
				  ptitcdt    IN VARCHAR2,    -- TCS_826 - ACL - 25/02/2019
                                  pnittit    IN VARCHAR2,    -- TCS_826 - ACL - 25/02/2019
                                  ptasa         IN VARCHAR2, --TCS 309 08/03/2019 AP
                                  piva          IN VARCHAR2, --TCS 309 08/03/2019 AP
                                  PFINIPAG      IN DATE,     --TCS 309 08/03/2019 AP
                                  PFFINPAG      IN DATE,     --TCS 309 08/03/2019 AP
                                  pcpoblacpag   IN NUMBER,   --TCS 309 08/03/2019 AP
                                  PCPROVINPAG   IN NUMBER,   --TCS 309 08/03/2019 AP
                                  PCPOBLACPAR   IN NUMBER,   --TCS 309 08/03/2019 AP
                                  PCPROVINPAR   IN NUMBER,   --TCS 309 08/03/2019 AP
                                  PCPOBLACFIR   IN NUMBER,   --TCS 309 08/03/2019 AP
                                  PCPROVINFIR   IN NUMBER,   --TCS 309 08/03/2019 AP
								  pnsinies	 IN NUMBER,		    -- TCS_319 - ACL - 13/03/2019
                                  pporcentaje  IN NUMBER,		-- TCS_319 - ACL - 13/03/2019
                                  pfoblig	  IN DATE,			-- TCS_319 - ACL - 13/03/2019
                                  pccuenta	  IN NUMBER, 		-- TCS_319 - ACL - 13/03/2019
                                  pncuenta	  IN VARCHAR2,		-- TCS_319 - ACL - 13/03/2019
								  ptexpagare  IN VARCHAR2,		-- TCS_319 - ACL - 18/03/2019
								  ptexiden	  IN VARCHAR2,		-- TCS_319 - ACL - 18/03/2019
                                  mensajes   IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_ins_contragaran_det';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || ' pnmovimi: ' ||
                                pnmovimi || ' pcpais: ' || pcpais ||
                                ' pfexpedic: ' || pfexpedic || ' pcbanco: ' ||
                                pcbanco || ' psperfide: ' || psperfide ||
                                ' ptsucursal: ' || ptsucursal ||
                                ' piinteres: ' || piinteres ||
                                ' piinteres: ' || piinteres ||
                                ' pfvencimi: ' || pfvencimi ||
                                ' pfvencimi1: ' || pfvencimi1 ||
                                ' pfvencimi2: ' || pfvencimi2 ||
                                ' pnplazo: ' || pnplazo || ' piasegura: ' ||
                                piasegura || ' piintcap: ' || piintcap ||
                                ' ptitcdt: ' || ptitcdt || ' pnittit: ' || pnittit ||   -- TCS_826 - ACL - 25/02/2019
								' pnsinies: ' || pnsinies ||
                                ' pporcentaje: ' || pporcentaje || ' pfoblig: ' || pfoblig ||
                                ' pccuenta: ' || pccuenta || ' pncuenta: ' || pncuenta ||
								' ptexpagare ' || ptexpagare || ' ptexiden ' || ptexiden;
      --
   BEGIN
      --
      INSERT INTO ctgar_det
         (scontgar, nmovimi, cpais, fexpedic, cbanco, sperfide, tsucursal,
          iinteres, fvencimi, fvencimi1, fvencimi2, nplazo, iasegura,
          iintcap, sinmueble, svehiculo, titcdt, nittit, tasa,iva,FINIPAG,FFINPAG,cpoblacpag,CPROVINPAG,CPOBLACPAR,CPROVINPAR,CPOBLACFIR,CPROVINFIR, nsinies, porcentaje, foblig, ccuenta, ncuenta, texpagare, texiden) --TCS 309 08/03/2019 AP
      VALUES
         (pscontgar, pnmovimi, pcpais, pfexpedic, pcbanco, psperfide,
          ptsucursal, piinteres, pfvencimi, pfvencimi1, pfvencimi2, pnplazo,
          piasegura, piintcap, NULL, NULL, ptitcdt, pnittit, ptasa,piva,PFINIPAG,PFFINPAG,pcpoblacpag,PCPROVINPAG,PCPOBLACPAR,PCPROVINPAR,PCPOBLACFIR,PCPROVINFIR, pnsinies, pporcentaje, pfoblig, pccuenta, pncuenta, ptexpagare, ptexiden); --TCS 309 08/03/2019 AP
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_ins_contragaran_det;

   /*************************************************************************
      FUNCTION f_ins_contragaran_cab

      param in mensajes  : t_iax_mensajes
      return             : NUMBER
   *************************************************************************/
   FUNCTION f_ins_contragaran_cab(pscontgar     IN NUMBER,
                                  pnmovimi      IN NUMBER,
                                  ptdescripcion IN VARCHAR2,
                                  pctipo        IN NUMBER,
								  pcarea        IN NUMBER,        -- TCS_450 - Bartolo Herrera - 07/03/2019
                                  pcclase       IN NUMBER,
                                  pcmoneda      IN VARCHAR2,
                                  pivalor       IN NUMBER,
                                  pfvencimi     IN DATE,
                                  pnempresa     IN NUMBER,
                                  pnradica      IN NUMBER,
                                  pfcrea        IN DATE,
                                  pdocumento    IN VARCHAR2,
                                  pctenedor     IN NUMBER,
                                  ptobsten      IN VARCHAR2,
                                  pcestado      IN NUMBER,
                                  pcorigen      IN NUMBER,
                                  ptcausa       IN VARCHAR2,
                                  ptauxilia     IN VARCHAR2,
                                  pcimpreso     IN NUMBER,
                                  pscontgar_out OUT NUMBER,
                                  pnmovimi_out  OUT NUMBER,
                                  mensajes      IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_ins_contragaran_cab';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar || 'pnmovimi: ' ||
                                pnmovimi || ' ptdescripcion: ' ||
                                ptdescripcion || ' pctipo: ' || pctipo ||
                                ' pcclase: ' || pcclase || ' pcmoneda: ' ||
                                pcmoneda || ' pivalor: ' || pivalor ||
                                ' pfvencimi: ' || pfvencimi ||
                                ' pnempresa: ' || pnempresa || 'pnradica: ' ||
                                pnradica || ' pfcrea: ' || pfcrea ||
                                ' pdocumento: ' || pdocumento ||
                                ' pctenedor: ' || pctenedor ||
                                ' ptobsten: ' || ptobsten || ' pcestado: ' ||
                                pcestado || ' pcorigen: ' || pcorigen ||
                                ' ptcausa: ' || ptcausa || ' ptauxilia: ' ||
                                ptauxilia;
      --
      v_scontgar NUMBER;
      v_nmovimi  NUMBER := 0;
      --
   BEGIN
      --
      IF pscontgar IS NULL
      THEN
         --
         v_scontgar := scontgar.nextval;
         --
         v_nmovimi := 1;
         --
      ELSE
         --
         v_scontgar := pscontgar;
         --
         SELECT nmovimi + 1
           INTO v_nmovimi
           FROM ctgar_contragarantia c
          WHERE c.scontgar = pscontgar
            AND c.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_contragarantia
                              WHERE scontgar = c.scontgar);
         --
      END IF;
      --
      INSERT INTO ctgar_contragarantia
         (scontgar, nmovimi, tdescripcion, ctipo, carea, cclase, cmoneda, ivalor,	-- TCS_450 - Bartolo Herrera - 07/03/2019
          fvencimi, nempresa, nradica, fcrea, documento, ctenedor, tobsten,
          cestado, corigen, tcausa, tauxilia, cimpreso, cusualt, falta)
      VALUES
         (v_scontgar, v_nmovimi, ptdescripcion, pctipo, pcarea, pcclase, pcmoneda,	-- TCS_450 - Bartolo Herrera - 07/03/2019
          pivalor, pfvencimi, pnempresa, NVL(pnradica, v_scontgar), pfcrea, pdocumento,
          pctenedor, ptobsten, pcestado, pcorigen, ptcausa, ptauxilia,
          pcimpreso, f_user, f_sysdate);
      --
      pscontgar_out := v_scontgar;
      pnmovimi_out  := v_nmovimi;
      --
      RETURN 0;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_ins_contragaran_cab;

   /*************************************************************************
      FUNCTION f_get_contragaran_mov

      param in pscontgar : Identificador contragaranta
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_contragaran_mov(pscontgar IN NUMBER,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_get_contragaran_mov';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      --
   BEGIN
      --
      OPEN v_cursor FOR
         SELECT c.scontgar,
                c.falta,
                c.cusualt,
                DECODE(nmovimi,
                       1,
                       f_axis_literales(9908845,
                                        pac_md_common.f_get_cxtidioma),
                       f_axis_literales(9908846,
                                        pac_md_common.f_get_cxtidioma)) situacion,
                ff_desvalorfijo(8001037, 8, c.ctenedor) ttenedor,
                ff_desvalorfijo(8001038, 8, c.cestado) testado
           FROM ctgar_contragarantia c
          WHERE c.scontgar = pscontgar
	  ORDER BY c.nmovimi ASC;
           -- Ini TCS_823 - ACL Se mofifica la consulta para que traiga la totalidad de registros.
          /*  AND c.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_contragarantia
                              WHERE scontgar = c.scontgar);  */
        -- Fin TCS_823 - ACL

      --
      RETURN v_cursor;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_mov;

   /*************************************************************************
      FUNCTION f_get_contragaran_pol

      param in pscontgar : Identificador contragaranta
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_contragaran_pol(pscontgar IN NUMBER,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_get_contragaran_pol';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      --
   BEGIN
      --
      OPEN v_cursor FOR
         SELECT c.scontgar,
                s.npoliza,
                s.nsolici,
                s.ncertif,
                s.sproduc,
                pac_isqlfor.f_plan(s.sseguro, pac_md_common.f_get_cxtidioma) plan,
                pac_seguros.ff_situacion_poliza(s.sseguro,
                                                pac_md_common.f_get_cxtidioma,
                                                2) situacion,
                (SELECT cusumov
                   FROM movseguro
                  WHERE sseguro = s.sseguro
                    AND cmovseg = 0) usuario
           FROM ctgar_contragarantia c,
                ctgar_seguro         cs,
                seguros              s
          WHERE c.scontgar = cs.scontgar
            AND s.sseguro = cs.sseguro
            AND c.scontgar = pscontgar
            AND c.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_contragarantia
                              WHERE scontgar = c.scontgar);

      --
      RETURN v_cursor;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_pol;

   /*************************************************************************
      FUNCTION f_get_contragaran_code

      param in pscontgar : Identificador contragaranta
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_contragaran_code(pscontgar IN NUMBER,
                                   mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_get_contragaran_code';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      --
   BEGIN
      --
      OPEN v_cursor FOR
         SELECT c.scontgar,
                p.sperson,
                ff_desvalorfijo(672, 8, p.ctipide) ctipide,
                p.nnumide,
                initcap(pac_isqlfor.f_dades_persona(p.sperson, 4, 5, 'POL') || ' ' ||
                        pac_isqlfor.f_dades_persona(p.sperson, 5, 5, 'POL')) nombre
           FROM ctgar_contragarantia c,
                ctgar_codeudor       d,
                per_personas         p
          WHERE c.scontgar = d.scontgar
            AND p.sperson = d.sperson
            AND c.scontgar = pscontgar
            AND c.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_contragarantia
                              WHERE scontgar = c.scontgar);

      --
      RETURN v_cursor;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_code;

   /*************************************************************************
      FUNCTION f_get_contragaran_det

      param in pscontgar : Identificador contragaranta
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_contragaran_det(pscontgar IN NUMBER,
                                  psperson  IN NUMBER DEFAULT NULL,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vsperson NUMBER;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_get_contragaran_det';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      --
   BEGIN
      --
      BEGIN
         SELECT spereal
           INTO vsperson
           FROM estper_personas
          WHERE sperson = psperson;
      EXCEPTION
         WHEN OTHERS THEN
            vsperson := NULL;
      END;
      --

      OPEN v_cursor FOR
         SELECT c.scontgar,
                p.sperson,
                pp.nnumide,
                pp.cagente,
                c.tdescripcion,
                c.ctipo,
				c.carea, -- TCS_450 - Bartolo Herrera - 07/03/2019
                ff_desvalorfijo(8001035, 8, c.ctipo) ttipo,
                c.cclase,
                ff_desvalorfijo(8001036, 8, c.cclase) tclase,
                c.ctenedor,
                ff_desvalorfijo(8001037, 8, c.ctenedor) ttenedor,
                c.cestado,
                ff_desvalorfijo(8001038, 8, c.cestado) testado,
                ivalor,
                0 cactivo,
                c.cmoneda,
                c.tcausa,
                c.corigen,
                c.documento,
                c.fcrea,
                c.nempresa,
                c.nradica,
                c.tauxilia,
                c.tobsten,
                cv.svehiculo,
                cv.cpais cpaisveh,
                cv.cprovin cprovinveh,
                cv.cpoblac cpoblacveh,
                cv.cmarca,
				cv.modelo,-- IAXIS-3053 BARTOLO HERRERA - 08/03/2019
                cv.nmotor,
                cv.nplaca,
                cv.ncolor,
                cv.nserie,
                cv.casegura,
                cv.ctipo ctipoveh,
                P.TPOBLAC AS TCPOBLACPAG, --TCS 309 08/03/2019 AP
                T.TPOBLAC AS TCPOBLACPAR, --TCS 309 08/03/2019 AP
                V.TPOBLAC AS TCPOBLACFIR, --TCS 309 08/03/2019 AP
                d.*,
                ci.sinmueble,
                ci.nnumescr,
                ci.fescritura,
                ci.tdescripcion tdescripinm,
                ci.tdireccion,
                ci.cpais cpaisinm,
                ci.cprovin cprovininm,
                ci.cpoblac cpoblacinm,
                fcertlib,
                cs.sseguro,
                pd.tapelli1 || ' ' || pd.tapelli2 || ' ' || pd.tnombre1 || ' ' ||
                pd.tnombre2 nombre,
                (SELECT tapelli1 || ' ' || tapelli2 || ' ' || tnombre1 || ' ' ||
                        tnombre2
                   FROM per_detper
                  WHERE sperson = d.sperfide) nombrefide
           FROM ctgar_contragarantia c,
                per_contragarantia   p,
                per_detper           pd,
                ctgar_det            d,
                per_personas         pp,
                ctgar_vehiculo       cv,
                ctgar_inmueble       ci,
                ctgar_seguro         cs,
                POBLACIONES P,       --TCS 309 08/03/2019 AP
                POBLACIONES T,       --TCS 309 08/03/2019 AP
                POBLACIONES V        --TCS 309 08/03/2019 AP
          WHERE p.scontgar = c.scontgar
            AND c.scontgar = pscontgar
            AND p.sperson = NVL(vsperson, p.sperson)
            AND pp.sperson = pd.sperson
            AND d.scontgar = c.scontgar
            AND c.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_contragarantia
                              WHERE scontgar = c.scontgar)
            AND d.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_det
                              WHERE scontgar = c.scontgar)
            AND pp.sperson = p.sperson
            AND c.scontgar = cs.scontgar(+)
            AND d.svehiculo = cv.svehiculo(+)
            AND d.sinmueble = ci.sinmueble(+)
            --
            AND P.CPROVIN(+) = D.CPROVINPAG --TCS 309 08/03/2019 AP
            AND P.CPOBLAC(+) = D.CPOBLACPAG --TCS 309 08/03/2019 AP
            ---
            AND T.CPROVIN(+) = D.CPROVINPAR --TCS 309 08/03/2019 AP
            AND T.CPOBLAC(+) = D.CPOBLACPAR --TCS 309 08/03/2019 AP
            --
            AND V.CPROVIN(+) = D.CPROVINFIR --TCS 309 08/03/2019 AP
            AND V.CPOBLAC(+) = D.CPOBLACFIR; --TCS 309 08/03/2019 AP
      --
      RETURN v_cursor;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_det;

   /*************************************************************************
      FUNCTION f_get_contragaran_cab

      param in psperson : Identificador persona
      param in pnradica : Numero de radicado
      param in psseguro : Identificador de seguro
      param in mensajes : t_iax_mensajes
      return            : t_iax_contragaran
   *************************************************************************/
   FUNCTION f_get_contragaran_cab(psperson IN NUMBER,
                                  pnradica IN VARCHAR2,
                                  psseguro IN NUMBER DEFAULT NULL,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_contragaran IS
      --
      v_contragaran ob_iax_contragaran;
      t_contragaran t_iax_contragaran;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_get_contragaran_cab';
      vparam   VARCHAR2(500) := 'psseguro: ' || psseguro || ' psperson: ' ||
                                psperson || ' pnradica: ' || pnradica;
      --

      CURSOR c_datos IS(
         SELECT c.scontgar,
                p.sperson,
                c.tdescripcion,
                ff_desvalorfijo(8001035, 8, c.ctipo) ttipo,
                ff_desvalorfijo(8001036, 8, c.cclase) tclase,
                ff_desvalorfijo(8001037, 8, c.ctenedor) ttenedor,
                ff_desvalorfijo(8001038, 8, c.cestado) testado,      -- TCS_ 818 - ACL - 20/02/2019 - Se cambia el nmero de lista de 8001039 a 8001038
                ivalor,
                DECODE((SELECT 1
                         FROM estctgar_seguro
                        WHERE scontgar = c.scontgar
                          AND sseguro = psseguro),
                       1,
                       1,
                       0) cactivo,
                c.nmovimi
           FROM ctgar_contragarantia c,
                per_contragarantia   p
          WHERE c.scontgar = p.scontgar
            AND p.sperson = NVL(psperson, p.sperson)
            AND c.nradica = NVL(pnradica, c.nradica)
            AND c.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_contragarantia
                              WHERE scontgar = c.scontgar));
      --

      CURSOR c_datos_n IS(
         SELECT c.scontgar,
                p.sperson,
                c.tdescripcion,
                ff_desvalorfijo(8001035, 8, c.ctipo) ttipo,
                ff_desvalorfijo(8001036, 8, c.cclase) tclase,
                ff_desvalorfijo(8001037, 8, c.ctenedor) ttenedor,
                ff_desvalorfijo(8001038, 8, c.cestado) testado,   -- TCS_ 818 - ACL - 20/02/2019 - Se cambia el nmero de lista de 8001039 a 8001038
                decode(c.cestado,2,(SELECT SUM (icapital)
                      FROM garanseg a
          WHERE a.sseguro = psseguro
            AND a.nmovimi =
                   (SELECT MAX (b.nmovimi)
                      FROM garanseg b
                     WHERE b.sseguro = a.sseguro
                       AND b.nriesgo = a.nriesgo
                       AND b.nmovimi = c.nmovimi)
), c.ivalor) ivalor,
                DECODE((SELECT 1
                         FROM estctgar_seguro
                        WHERE scontgar = c.scontgar
                          AND sseguro = psseguro),
                       1,
                       1,
                       0) cactivo,
                c.nmovimi
           FROM ctgar_contragarantia c,
                per_contragarantia   p
          WHERE p.scontgar = c.scontgar
            AND p.sperson = NVL(psperson, p.sperson)
            AND c.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_contragarantia
                              WHERE scontgar = c.scontgar))
          ORDER BY cactivo DESC;
      --

   BEGIN
      --
      IF psseguro IS NULL
      THEN
         --
         vpasexec      := 1;
         t_contragaran := t_iax_contragaran();
         --
         FOR c_dat IN c_datos
         LOOP
            --
            v_contragaran := ob_iax_contragaran();
            --
            v_contragaran.scontgar := c_dat.scontgar;
            v_contragaran.sperson  := c_dat.sperson;
            v_contragaran.tdescrip := c_dat.tdescripcion;
            v_contragaran.ttipo    := c_dat.ttipo;
            v_contragaran.tclase   := c_dat.tclase;
            v_contragaran.ttenedor := c_dat.ttenedor;
            v_contragaran.testado  := c_dat.testado;
            v_contragaran.ivalor   := c_dat.ivalor;
            v_contragaran.cactivo  := c_dat.cactivo;
            v_contragaran.nmovimi  := c_dat.nmovimi;
            --
            t_contragaran.extend;
            t_contragaran(t_contragaran.last) := v_contragaran;
            --
         END LOOP;
         --
      ELSE
         --
         vpasexec      := 2;
         t_contragaran := t_iax_contragaran();
         --
         FOR c_dat IN c_datos_n
         LOOP
            --
            v_contragaran := ob_iax_contragaran();
            --
            v_contragaran.scontgar := c_dat.scontgar;
            v_contragaran.sperson  := c_dat.sperson;
            v_contragaran.tdescrip := c_dat.tdescripcion;
            v_contragaran.ttipo    := c_dat.ttipo;
            v_contragaran.tclase   := c_dat.tclase;
            v_contragaran.ttenedor := c_dat.ttenedor;
            v_contragaran.testado  := c_dat.testado;
            v_contragaran.ivalor   := c_dat.ivalor;
            v_contragaran.cactivo  := c_dat.cactivo;
            v_contragaran.nmovimi  := c_dat.nmovimi;
            --
            t_contragaran.extend;
            t_contragaran(t_contragaran.last) := v_contragaran;
            --
         END LOOP;
         --
      END IF;
      --
      RETURN t_contragaran;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_cab;

   /*************************************************************************
      FUNCTION f_get_contragaran_cab

      param in psseguro : Identificador de seguro
      param in mensajes : t_iax_mensajes
      return            : t_iax_contragaran
   *************************************************************************/
   FUNCTION f_get_contragaran_seg(psseguro IN NUMBER,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_contragaran IS
      --
      v_contragaran ob_iax_contragaran;
      t_contragaran t_iax_contragaran;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_get_contragaran_seg';
      vparam   VARCHAR2(500) := 'psseguro: ' || psseguro;
      --

      CURSOR c_datos IS(
         SELECT c.scontgar,
                p.sperson,
                c.tdescripcion,
                ff_desvalorfijo(8001035, 8, c.ctipo) ttipo,
                ff_desvalorfijo(8001036, 8, c.cclase) tclase,
                ff_desvalorfijo(8001037, 8, c.ctenedor) ttenedor,
                ff_desvalorfijo(8001039, 8, c.cestado) testado,
                ivalor,
                1 cactivo,
                c.nmovimi
           FROM ctgar_contragarantia c,
                per_contragarantia   p,
                ctgar_seguro         cs
          WHERE c.scontgar = p.scontgar
            AND c.scontgar = cs.scontgar
            AND cs.sseguro = psseguro
            AND c.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_contragarantia
                              WHERE scontgar = c.scontgar)
         UNION
         SELECT c.scontgar,
                p.sperson,
                c.tdescripcion,
                ff_desvalorfijo(8001035, 8, c.ctipo) ttipo,
                ff_desvalorfijo(8001036, 8, c.cclase) tclase,
                ff_desvalorfijo(8001037, 8, c.ctenedor) ttenedor,
                ff_desvalorfijo(8001039, 8, c.cestado) testado,
                ivalor,
                1 cactivo,
                c.nmovimi
           FROM ctgar_contragarantia c,
                per_contragarantia   p,
                estctgar_seguro      cs
          WHERE c.scontgar = p.scontgar
            AND c.scontgar = cs.scontgar
            AND cs.sseguro = psseguro
            AND c.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_contragarantia
                              WHERE scontgar = c.scontgar));
      --

   BEGIN
      --
      vpasexec      := 1;
      t_contragaran := t_iax_contragaran();
      --
      FOR c_dat IN c_datos
      LOOP
         --
         v_contragaran := ob_iax_contragaran();
         --
         v_contragaran.scontgar := c_dat.scontgar;
         v_contragaran.sperson  := c_dat.sperson;
         v_contragaran.tdescrip := c_dat.tdescripcion;
         v_contragaran.ttipo    := c_dat.ttipo;
         v_contragaran.tclase   := c_dat.tclase;
         v_contragaran.ttenedor := c_dat.ttenedor;
         v_contragaran.testado  := c_dat.testado;
         v_contragaran.ivalor   := c_dat.ivalor;
         v_contragaran.cactivo  := c_dat.cactivo;
         v_contragaran.nmovimi  := c_dat.nmovimi;
         --
         t_contragaran.extend;
         t_contragaran(t_contragaran.last) := v_contragaran;
         --
      END LOOP;
      --
      RETURN t_contragaran;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_seg;
   --
   FUNCTION f_getrelacion_sperson(psperson  IN NUMBER,
                                  ptablas   IN VARCHAR2,
                                  mensajes  IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      v_cursor SYS_REFCURSOR;
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_getrelacion_sperson';
      vparam   VARCHAR2(500) := 'psperson: ' || psperson || ', ptablas: ' || ptablas;
      -- Ini TCS_309 - ACL - 14/02/2019
      v_count  NUMBER;
      vquery   VARCHAR2(10000);
      vtabla   VARCHAR2(1000);
      vsperson VARCHAR2(1000);

      CURSOR c1 IS
        select DISTINCT p.sperson
         from ctgar_codeudor c, per_contragarantia p
         where c.scontgar = p.scontgar
          and c.sperson = psperson;

   BEGIN
   /* IF ptablas = 'EST' THEN
         OPEN v_cursor FOR
         SELECT p.sperson,c.scontgar nctrgarant,
                c.tdescripcion tctrgarant,
                c.ctipo ctipo,
                ff_desvalorfijo(8001035, 8, c.ctipo) ttipo,
                c.cclase cclase,
                ff_desvalorfijo(8001036, 8, c.cclase) tclase,
                c.cmoneda cmoneda,
                '' tmodena,
                c.cestado cestado,
                ff_desvalorfijo(8001039, 8, c.cestado) testado,
                ivalor nvalor,
                (SELECT COUNT (*)
                    FROM ctgar_codeudor
                    where sperson  = psperson) crol,    -- TCS_309 - ACL - 13/02/2019 Se agrega condicion para el campo crol
                '' trol,c.nmovimi
           FROM ctgar_contragarantia c,
                estper_contragarantia   p
          WHERE c.scontgar = p.scontgar
            AND p.sperson = NVL(psperson, p.sperson)
            AND c.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_contragarantia
                              WHERE scontgar = c.scontgar);
   ELSE
         OPEN v_cursor FOR
         SELECT p.sperson,c.scontgar nctrgarant,
                c.tdescripcion tctrgarant,
                c.ctipo ctipo,
                ff_desvalorfijo(8001035, 8, c.ctipo) ttipo,
                c.cclase cclase,
                ff_desvalorfijo(8001036, 8, c.cclase) tclase,
                c.cmoneda cmoneda,
                '' tmodena,
                c.cestado cestado,
                ff_desvalorfijo(8001039, 8, c.cestado) testado,
                ivalor nvalor,
                (SELECT COUNT (*)
                    FROM ctgar_codeudor
                    where sperson  = psperson) crol,   -- TCS_309 - ACL - 13/02/2019 Se agrega condicion para el campo crol
                '' trol,c.nmovimi
           FROM ctgar_contragarantia c,
                per_contragarantia   p
          WHERE c.scontgar = p.scontgar
            AND p.sperson = NVL(psperson, p.sperson)
            AND c.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_contragarantia
                              WHERE scontgar = c.scontgar);
      END IF; */

      SELECT COUNT (*)
         INTO v_count
         FROM ctgar_codeudor c
             where c.sperson  = psperson;

    IF v_count = 0 THEN
       IF ptablas = 'EST' THEN
            vtabla := ' estper_contragarantia p ';
            vsperson := '(NVL( ' || psperson || ', p.sperson))';
       ELSE
          vtabla :=  ' per_contragarantia p ';
          vsperson := '(NVL( ' || psperson || ', p.sperson))';
       END IF;
    ELSE
       IF ptablas = 'EST' THEN
        vtabla := ' estper_contragarantia p ';
        vsperson := '( ';

        FOR co1 IN c1 LOOP
            vsperson := vsperson||co1.sperson||',' ;
          END LOOP;

        vsperson := substr(vsperson,1,LENGTH(vsperson)-1);
        vsperson  := vsperson ||')';

       ELSE
        vtabla :=  ' per_contragarantia p ';
        vsperson := '( ';

        FOR co1 IN c1 LOOP
            vsperson := vsperson||co1.sperson||',' ;
          END LOOP;

        vsperson := substr(vsperson,1,LENGTH(vsperson)-1);
        vsperson  := vsperson ||')';
       END IF;
    END IF;

     vquery :=  ' SELECT p.sperson,c.scontgar nctrgarant, ' ||
                ' c.tdescripcion tctrgarant, ' ||
                ' c.ctipo ctipo, ' ||
                ' ff_desvalorfijo(8001035, 8, c.ctipo) ttipo, ' ||
                ' c.cclase cclase, ' ||
                ' ff_desvalorfijo(8001036, 8, c.cclase) tclase, ' ||
                ' c.cmoneda cmoneda, ' ||
                ' '''' tmodena, ' ||
                ' c.cestado cestado, ' ||
                ' ff_desvalorfijo(8001038, 8, c.cestado) testado, ' ||     -- TCS_ 818 - ACL - 18/02/2019 - Se cambia el nmero de lista de 8001039 a 8001038
                ' ivalor nvalor, ' ||
                ' (SELECT COUNT (*)  ' ||
                ' FROM ctgar_codeudor ' ||
                ' where sperson  = ' || psperson || ') crol, ' ||
                ' '''' trol,c.nmovimi ' ||
                ' FROM ctgar_contragarantia c, ' || vtabla ||
                ' WHERE c.scontgar = p.scontgar ' ||
                ' AND p.sperson IN ' || vsperson ||
                ' AND c.nmovimi = (SELECT MAX(nmovimi) ' ||
                ' FROM ctgar_contragarantia ' ||
                ' WHERE scontgar = c.scontgar) ';

      OPEN v_cursor FOR vquery;
      -- Fin TCS_309 - ACL - 14/02/2019
      RETURN v_cursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_getrelacion_sperson;

   --Inicio Bartolo Herrera 04-03-2019 ---- IAXIS-2826
   /*************************************************************************
      FUNCTION f_get_contragaran_cab2

      param in psperson : Identificador persona
      param in pnradica : Numero de radicado
      param in psseguro : Identificador de seguro
      param in mensajes : t_iax_mensajes
      return            : t_iax_contragaran
   *************************************************************************/
   FUNCTION f_get_contragaran_cab2(psperson IN NUMBER,
                                  pnradica IN VARCHAR2,
                                  psseguro IN NUMBER DEFAULT NULL,
                                  mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_contragaran IS
      --
      v_contragaran ob_iax_contragaran;
      t_contragaran t_iax_contragaran;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_get_contragaran_cab';
      vparam   VARCHAR2(500) := 'psseguro: ' || psseguro || ' psperson: ' ||
                                psperson || ' pnradica: ' || pnradica;
      --

      CURSOR c_datos IS(
         SELECT c.scontgar,
                p.sperson,
                c.tdescripcion,
                ff_desvalorfijo(8001035, 8, c.ctipo) ttipo,
                ff_desvalorfijo(8001036, 8, c.cclase) tclase,
                ff_desvalorfijo(8001037, 8, c.ctenedor) ttenedor,
                ff_desvalorfijo(8001038, 8, c.cestado) testado,
                ivalor,
                DECODE((SELECT 1
                         FROM estctgar_seguro
                        WHERE scontgar = c.scontgar
                          AND sseguro = psseguro),
                       1,
                       1,
                       0) cactivo,
                c.nmovimi
           FROM ctgar_contragarantia c,
                per_contragarantia   p
          WHERE c.scontgar = p.scontgar
            AND p.sperson = NVL(psperson, p.sperson)
            AND c.nradica = NVL(pnradica, c.nradica)
            AND c.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_contragarantia
                              WHERE scontgar = c.scontgar)
             and c.scontgar not in (SELECT a.scontgar FROM CTGAR_CONTRAGARANTIA a,CTGAR_SEGURO b WHERE a.scontgar=b.scontgar AND A.scontgar  =c.scontgar  AND A.CESTADO = 2));
      --
      CURSOR c_datos_n IS(
         SELECT c.scontgar,
                p.sperson,
                c.tdescripcion,
                ff_desvalorfijo(8001035, 8, c.ctipo) ttipo,
                ff_desvalorfijo(8001036, 8, c.cclase) tclase,
                ff_desvalorfijo(8001037, 8, c.ctenedor) ttenedor,
                ff_desvalorfijo(8001038, 8, c.cestado) testado,
                ivalor,
                DECODE((SELECT 1
                         FROM estctgar_seguro
                        WHERE scontgar = c.scontgar
                          AND sseguro = psseguro),
                       1,
                       1,
                       0) cactivo,
                c.nmovimi
           FROM ctgar_contragarantia c,
                per_contragarantia   p
          WHERE p.scontgar = c.scontgar
            AND p.sperson = NVL(psperson, p.sperson)
            AND c.nmovimi = (SELECT MAX(nmovimi)
                               FROM ctgar_contragarantia
                              WHERE scontgar = c.scontgar)
         and c.scontgar not in (SELECT a.scontgar FROM CTGAR_CONTRAGARANTIA a,CTGAR_SEGURO b WHERE a.scontgar=b.scontgar AND A.scontgar  =c.scontgar  AND A.CESTADO   =2))
          ORDER BY cactivo DESC;
      --

   BEGIN
      --
      IF psseguro IS NULL
      THEN
         --
         vpasexec      := 1;
         t_contragaran := t_iax_contragaran();
         --
         FOR c_dat IN c_datos
         LOOP
            --
            v_contragaran := ob_iax_contragaran();
            --
            v_contragaran.scontgar := c_dat.scontgar;
            v_contragaran.sperson  := c_dat.sperson;
            v_contragaran.tdescrip := c_dat.tdescripcion;
            v_contragaran.ttipo    := c_dat.ttipo;
            v_contragaran.tclase   := c_dat.tclase;
            v_contragaran.ttenedor := c_dat.ttenedor;
            v_contragaran.testado  := c_dat.testado;
            v_contragaran.ivalor   := c_dat.ivalor;
            v_contragaran.cactivo  := c_dat.cactivo;
            v_contragaran.nmovimi  := c_dat.nmovimi;
            --
            t_contragaran.extend;
            t_contragaran(t_contragaran.last) := v_contragaran;
            --
         END LOOP;
         --
      ELSE
         --
         vpasexec      := 2;
         t_contragaran := t_iax_contragaran();
         --
         FOR c_dat IN c_datos_n
         LOOP
            --
            v_contragaran := ob_iax_contragaran();
            --
            v_contragaran.scontgar := c_dat.scontgar;
            v_contragaran.sperson  := c_dat.sperson;
            v_contragaran.tdescrip := c_dat.tdescripcion;
            v_contragaran.ttipo    := c_dat.ttipo;
            v_contragaran.tclase   := c_dat.tclase;
            v_contragaran.ttenedor := c_dat.ttenedor;
            v_contragaran.testado  := c_dat.testado;
            v_contragaran.ivalor   := c_dat.ivalor;
            v_contragaran.cactivo  := c_dat.cactivo;
            v_contragaran.nmovimi  := c_dat.nmovimi;
            --
            t_contragaran.extend;
            t_contragaran(t_contragaran.last) := v_contragaran;
            --
         END LOOP;
         --
      END IF;
      --
      RETURN t_contragaran;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_contragaran_cab2;
   --Fin Bartolo Herrera 04-03-2019 ---- IAXIS-2826
   --INI TCS 309 08/03/2019 AP
   FUNCTION f_getPagareCartera (pscontgar  IN NUMBER)
      RETURN varchar2 IS
     -- cur            sys_refcursor;
     vquery         VARCHAR2(32767);--CLOB;
     vquery2         VARCHAR2(32767);
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_getPagareCartera';
      vparam   VARCHAR2(500) := 'pscontgar: ' || pscontgar;
      VSCONTGAR NUMBER;--(38,100);
      VNOMBRE VARCHAR2(500);
      VNNUMIDE VARCHAR2(100);
      VCIUDAD VARCHAR2(500);
      VNOMBRE_REP VARCHAR2(500);
      VNNUMIDE_REP VARCHAR2(500);
      VCIUDAD_REP VARCHAR2(500);
      VVALOR VARCHAR2(100);
      VINTERES VARCHAR2(500);
      VTASA VARCHAR2(500);
      VIVA VARCHAR2(500);
      VCUOTAS NUMBER;
      VFINIPAG DATE;
      VDIAI NUMBER;
      VTMESI VARCHAR2(100);
      VANIOI NUMBER;
      VFFINPAG DATE;
      VDIAF NUMBER;
      VTMESF VARCHAR2(100);
      VANIOF NUMBER;
      VTCPOBLACPAG VARCHAR2(500);
      VTCPOBLACPAR VARCHAR2(500);
      VTCPOBLACFIR VARCHAR2(500);
      VDIA NUMBER;
      VTMES VARCHAR2(100);
      VANIO NUMBER;
      VMONEDA VARCHAR2(500);
      VTMONEDA VARCHAR2(500);
      letras varchar2(1000);
      DMONEDA VARCHAR2(100):= NULL;
      VVALOR2   VARCHAR2(1000) := NULL;
      VINTERES2 VARCHAR2(1000) := NULL;
      VIVA2 VARCHAR2(1000) := NULL;
      DIFVVALOR NUMBER := 0;
      DIFVINTERES NUMBER := 0;
      DIFVIVA NUMBER := 0;
      RELETRAS varchar2(1000);
      ret number;
   BEGIN

   SELECT DISTINCT c.scontgar,
    C.CMONEDA,
    M.TDESCRI,
    (SELECT DECODE(pd.TNOMBRE1, NULL, NULL, pd.TNOMBRE1 || ' ') ||  DECODE(pd.TNOMBRE2, NULL, NULL, pd.TNOMBRE2 ||' ') ||  DECODE(pd.TAPELLI1, NULL, NULL, pd.TAPELLI1 ||' ') ||  DECODE(pd.TAPELLI2, NULL, NULL, pd.TAPELLI2 || ' ')
    FROM   per_detper pd WHERE  pd.sperson = p.sperson) ttomador,
    pp.nnumide,
    (SELECT max(tpoblac) FROM per_direcciones pr, poblaciones po WHERE pr.sperson = p.sperson AND pr.cdomici = (select max(cdomici)
    from per_direcciones where sperson = p.sperson) AND pr.cprovin = po.cprovin AND pr.cpoblac = po.cpoblac) ciudad,
    (NVL ((SELECT DECODE(pd.TNOMBRE1, NULL, NULL, pd.TNOMBRE1 || ' ') ||  DECODE(pd.TNOMBRE2, NULL, NULL, pd.TNOMBRE2 ||' ') ||  DECODE(pd.TAPELLI1, NULL, NULL, pd.TAPELLI1 ||' ') ||  DECODE(pd.TAPELLI2, NULL, NULL, pd.TAPELLI2 || ' ') FROM   per_detper pd WHERE  pd.sperson = (select sr.sperson_rel from per_personas_rel sr where sr.sperson = p.sperson)), NULL)) reprlegal,
    (NVL ((select pe.nnumide from per_personas pe where pe.sperson = (select sr.sperson_rel from per_personas_rel sr  where sr.sperson = p.sperson)), NULL)) idreprlegal,
    (SELECT max(tpoblac) FROM per_direcciones pr, poblaciones po WHERE pr.sperson = (select sr.sperson_rel from per_personas_rel sr  where sr.sperson = p.sperson) AND pr.cdomici = (select max(cdomici)
    from per_direcciones where sperson = (select sr.sperson_rel from per_personas_rel sr  where sr.sperson = p.sperson)) AND pr.cprovin = po.cprovin AND pr.cpoblac = po.cpoblac) ciudad_rep,
    REPLACE(c.ivalor,'.', '') valor,
    REPLACE(d.iinteres,'.', '') interes,
    d.TASA TASA,
    REPLACE(d.IVA,'.', '') IVA,
    d.nplazo cuotas,
    D.FINIPAG FINIPAG,
    (SELECT EXTRACT(DAY FROM D.FINIPAG) FROM dual) dia,
    (SELECT to_char(D.FINIPAG, 'Month','nls_date_language=spanish') FROM dual) tmes,
    (SELECT EXTRACT(YEAR FROM D.FINIPAG) FROM dual) anio,
    D.FFINPAG FFINPAG,
    (SELECT EXTRACT(DAY FROM D.FFINPAG) FROM dual) dia,
    (SELECT to_char(D.FFINPAG, 'Month','nls_date_language=spanish') FROM dual) tmes,
    (SELECT EXTRACT(YEAR FROM D.FFINPAG) FROM dual) anio,
    PS.TPOBLAC AS TCPOBLACPAG,
    T.TPOBLAC AS TCPOBLACPAR,
    V.TPOBLAC AS TCPOBLACFIR,
    (SELECT EXTRACT(DAY FROM f_sysdate) FROM dual) dia,
    (SELECT to_char(f_sysdate, 'Month','nls_date_language=spanish') FROM dual) tmes,
    (SELECT EXTRACT(YEAR FROM f_sysdate) FROM dual) anio
    INTO VSCONTGAR, VMONEDA, VTMONEDA, VNOMBRE, VNNUMIDE , VCIUDAD, VNOMBRE_REP, VNNUMIDE_REP, VCIUDAD_REP, VVALOR, VINTERES, VTASA, VIVA, VCUOTAS , VFINIPAG, VDIAI, VTMESI, VANIOI, VFFINPAG, VDIAF, VTMESF, VANIOF, VTCPOBLACPAG, VTCPOBLACPAR, VTCPOBLACFIR, VDIA, VTMES, VANIO
             FROM ctgar_contragarantia c,
                    per_contragarantia   p,
                    per_detper           pd,
                    ctgar_det            d,
                    per_personas         pp,
                    ctgar_seguro         cs,
                    POBLACIONES PS,
                    POBLACIONES T,
                    POBLACIONES V,
                    MONEDAS M
              WHERE p.scontgar = c.scontgar
                AND c.scontgar = pscontgar
                AND pp.sperson = pd.sperson
                AND d.scontgar = c.scontgar
                AND d.nmovimi = (SELECT MAX(nmovimi)
                                   FROM ctgar_det
                                  WHERE scontgar = pscontgar)
                AND c.nmovimi = (SELECT MAX(nmovimi)
                                   FROM ctgar_contragarantia
                                  WHERE scontgar = pscontgar)
                AND pp.sperson = p.sperson
                AND c.scontgar = cs.scontgar(+)
                --
                AND PS.CPROVIN(+) = D.CPROVINPAG
                AND PS.CPOBLAC(+) = D.CPOBLACPAG
                ---
                AND T.CPROVIN(+) = D.CPROVINPAR
                AND T.CPOBLAC(+) = D.CPOBLACPAR
                --
                AND V.CPROVIN(+) = D.CPROVINFIR
                AND V.CPOBLAC(+) = D.CPOBLACFIR
                --
                AND C.CMONEDA = M.CMONINT(+)
                AND M.CIDIOMA = 8;
    ----
    BEGIN
        SELECT (to_char(VVALOR,'999G999G999G999G999D00', 'NLS_NUMERIC_CHARACTERS = '',.''')),
        (to_char(VINTERES,'999G999G999G999G999D00', 'NLS_NUMERIC_CHARACTERS = '',.''')), 
        (to_char(VIVA,'999G999G999G999G999D00', 'NLS_NUMERIC_CHARACTERS = '',.''')) 
        INTO VVALOR2, VINTERES2, VIVA2
        FROM DUAL;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
    ----
    BEGIN
        SELECT MOD(VVALOR,1000000) , MOD(VINTERES,1000000) , MOD(VIVA,1000000) 
        INTO DIFVVALOR, DIFVINTERES, DIFVIVA
        FROM DUAL;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
    ----
    IF  VMONEDA = 'COP' THEN
    VMONEDA := '$';
    DMONEDA := ' m/cte';
    END IF;

    vquery := vquery || 'SELECT ' ||CHR(39);

    IF VNOMBRE_REP IS NOT NULL THEN
    vquery:= vquery || VNOMBRE_REP || ' mayor de edad ';
    ELSE
    vquery:= vquery || VNOMBRE || ' mayor de edad ';
    END IF;
    ----
    IF VCIUDAD_REP IS NOT NULL THEN
    vquery := vquery || ' y vecino de la ciudad de ' || VCIUDAD_REP || ', ';
    ELSE
    vquery := vquery || ' y vecino de la ciudad de ' || VCIUDAD || ', ';
    END IF;

    IF VNNUMIDE_REP IS NOT NULL THEN
    vquery := vquery || 'identificado con la cedula de ciudadania No.' || VNNUMIDE_REP;
    ELSE
    vquery := vquery || 'identificado con la cedula de ciudadania No.' || VNNUMIDE;
    END IF;

    vquery := vquery ||' actuando en nombre propio';

    IF VNOMBRE IS NOT NULL AND VNOMBRE_REP IS NOT NULL THEN
    vquery := vquery ||' y en mi calidad de representante legal de la sociedad ' || VNOMBRE ||', sociedad comercial ';
    END IF;

    IF VCIUDAD IS NOT NULL AND VCIUDAD_REP IS NOT NULL THEN
    vquery := vquery ||' con domicilio principal en la ciudad de '||VCIUDAD||',';
    END IF;

    IF VNNUMIDE IS NOT NULL AND VNNUMIDE_REP IS NOT NULL THEN
    vquery := vquery ||' con Nit.'|| VNNUMIDE || ' como acredito con el certificado de existencia y representacion expedido por la Camara de Comercio';
    END IF;

    IF VNOMBRE_REP IS NOT NULL THEN
    vquery := vquery ||', declaro: PRIMERO. Que en virtud del presente titulo valor pagaremos incondicionalmente,';
    ELSE
    vquery := vquery ||', declaro: PRIMERO. Que en virtud del presente titulo valor pagare incondicionalmente,';
    END IF;

    IF VTCPOBLACPAG IS NOT NULL THEN
    vquery := vquery ||' en la ciudad de ' || VTCPOBLACPAG;
    END IF;

    vquery := vquery ||' a la orden de la COMPA'|| CHR(38)||'Ntilde;IA ASEGURADORA DE FIANZAS S.A. CONFIANZA, sociedad comercial con Nit. 860.070.374-9, o a quien represente sus derechos';

    IF VVALOR IS NOT NULL THEN
    ----
    BEGIN
    LETRAS := null;
    ret := f_numlet (8,VVALOR,8,LETRAS);
    END;
    ---
        IF DIFVVALOR = 0 THEN
            vquery := vquery ||' la suma de '|| LETRAS ||' DE ' || VTMONEDA ||'  ' || DMONEDA ||' (' || VMONEDA ||' '|| VVALOR2 ||'),';
        ELSE
            vquery := vquery ||' la suma de '|| LETRAS ||' ' || VTMONEDA ||'  ' || DMONEDA ||' (' || VMONEDA ||' '|| VVALOR2 ||'),';
        END IF;
    ---
    END IF;

    vquery := vquery ||' como capital por concepto de financiacion de primas conforme a lo estipulado en la Resolucion 420 de febrero 12 de 1993 expedida por la Superintendencia Financiera de Colombia, e incorporada en la Circular Basica Juridica No. 007 de 1996,';

    IF VINTERES IS NOT NULL THEN
    BEGIN
    LETRAS := null;
    ret := f_numlet (8,VINTERES,8,LETRAS);
    END;
    ---
        IF DIFVINTERES = 0 THEN
            vquery := vquery ||'  junto con los intereses que corresponden a la suma de '|| LETRAS|| ' DE ' || VTMONEDA ||' ' || DMONEDA ||' (' || VMONEDA ||' '||VINTERES2||'),';
        ELSE    
            vquery := vquery ||'  junto con los intereses que corresponden a la suma de '|| LETRAS|| ' ' || VTMONEDA ||' ' || DMONEDA ||' (' || VMONEDA ||' '||VINTERES2||'),';
        END IF;
    END IF;

    IF VTASA IS NOT NULL THEN
    vquery := vquery ||' liquidados a la tasa nominal anual MV '||VTASA||' %,';
    END IF;

    IF VIVA IS NOT NULL THEN
    BEGIN
    LETRAS := null;
    ret := f_numlet (8,VIVA,8,LETRAS);
    END;
    ---
        IF DIFVIVA = 0 THEN
            vquery := vquery ||' y la suma de '|| LETRAS|| ' DE ' || VTMONEDA ||'  ' || DMONEDA ||' (' || VMONEDA ||' '||VIVA2||') del IVA por los intereses, que la compa'|| CHR(38)||'ntilde;ia Aseguradora de Fianzas S.A deba pagar a la Administracion de Impuestos a medida que se vayan causando.';
        ELSE
            vquery := vquery ||' y la suma de '|| LETRAS|| ' ' || VTMONEDA ||'  ' || DMONEDA ||' (' || VMONEDA ||' '||VIVA2||') del IVA por los intereses, que la compa'|| CHR(38)||'ntilde;ia Aseguradora de Fianzas S.A deba pagar a la Administracion de Impuestos a medida que se vayan causando.';
        END IF;
    END IF;

    IF VNOMBRE_REP IS NOT NULL THEN
    vquery := vquery || ' SEGUNDO. Pagaremos la suma indicada en la clausula anterior';
    ELSE
    vquery := vquery || ' SEGUNDO. Pagare la suma indicada en la clausula anterior';
    END IF;

    IF VTCPOBLACPAG IS NOT NULL THEN
    vquery := vquery ||' en las oficinas de '||VTCPOBLACPAG||',';
    END IF;

    vquery := vquery ||' mediante instalamentos mensuales sucesivos';

    IF VCUOTAS IS NOT NULL THEN
    BEGIN
    LETRAS := null;
        IF VCUOTAS = 1 THEN
            LETRAS := 'UNA';
            vquery := vquery || ' y en '|| LETRAS ||' ('|| VCUOTAS ||') cuota,';
        ELSE
    ret := f_numlet (8,VCUOTAS,8,LETRAS);
            vquery := vquery || ' y en '|| LETRAS ||' ('|| VCUOTAS ||') cuotas,';
        END IF;
    END;
    END IF;

    vquery := vquery ||' en pesos colombianos, correspondientes,';

    IF VFINIPAG IS NOT NULL THEN
    BEGIN
    LETRAS := null;
    RELETRAS := null;
    ret := f_numlet (8,VDIAI,8,LETRAS);
        BEGIN
            SELECT REPLACE(LETRAS,'UN','UNO') 
            INTO RELETRAS
            FROM DUAL;
        EXCEPTION WHEN OTHERS THEN
            NULL;
        END;
    LETRAS := RELETRAS;
    END;
    vquery := vquery ||' a partir del dia '|| LETRAS||' ('||VDIAI||') del mes de '||VTMESI||' del a'|| CHR(38)||'ntilde;o '||VANIOI;
    END IF;

    IF VFFINPAG IS NOT NULL THEN
    BEGIN
    LETRAS := null;
    RELETRAS := null;
    ret := f_numlet (8,VDIAF,8,LETRAS);
        BEGIN
            SELECT REPLACE(LETRAS,'UN','UNO') 
            INTO RELETRAS
            FROM DUAL;
        EXCEPTION WHEN OTHERS THEN
            NULL;
        END;
    LETRAS := RELETRAS;
    END;
    vquery := vquery ||' hasta el dia '|| LETRAS||' ('||VDIAF||') del mes de '||VTMESF||' del a'|| CHR(38)||'ntilde;o '||VANIOF||',';
    END IF;

    IF VNOMBRE_REP IS NOT NULL THEN
    vquery := vquery ||' segun se detalle en la tabla de amortizacion que forma parte integrante del presente titulo valor. TERCERO. En caso de mora reconoceremos intereses moratorios a la tasa mensual vigente en el momento de la mora. CUARTO. Clausula aceleratoria. Autorizamos a Confianza S.A. para declarar vencido el plazo y exigir la cancelacion inmediata del saldo pendiente a su favor por el incumplimiento en el pago de cualquiera de las cuotas, mas los intereses moratorios a la tasa autorizada por la Superintendencia Financiera de Colombia, en el momento del incumplimiento. QUINTO. Seran de nuestro cargo las costas y honorarios de abogado en caso de cobro prejudicial y judicial, que desde ahora se pactan en un 20% del total de la obligacion en cualquiera de los siguientes eventos: a) El incumplimiento en el pago de una o mas cuotas, o la mora de mas de 30 dias; b) si la sociedad fuere demandada judicialmente o se le embarguen los bienes por cualquier clase de accion que afecte considerablemente su patrimonio; c) En caso de declaratoria de quiebra, o concurso de acreedores, inhabilidad e incapacidad de uno o varios de los que firman el presente documento. SEXTO. En caso de causarse impuesto de timbre sobre el presente titulo valor, su costo correra a cargo del deudor y sera pagado a favor de la Administracion de Impuestos directamente, a la firma del presente pagare. SEPTIMO. Autorizamos desde ahora para que el presente titulo valor sea transferido por endoso segun lo establecido en el articulo 651 y siguientes del Codigo del Comercio. OCTAVO.';
    ELSE
    vquery := vquery ||' segun se detalle en la tabla de amortizacion que forma parte integrante del presente titulo valor. TERCERO. En caso de mora reconocere intereses moratorios a la tasa mensual vigente en el momento de la mora. CUARTO. Clausula aceleratoria. Autorizo a Confianza S.A. para declarar vencido el plazo y exigir la cancelacion inmediata del saldo pendiente a su favor por el incumplimiento en el pago de cualquiera de las cuotas, mas los intereses moratorios a la tasa autorizada por la Superintendencia Financiera de Colombia, en el momento del incumplimiento. QUINTO. Sera de mi cargo las costas y honorarios de abogado en caso de cobro prejudicial y judicial, que desde ahora se pactan en un 20% del total de la obligacion en cualquiera de los siguientes eventos: a) El incumplimiento en el pago de una o mas cuotas, o la mora de mas de 30 dias; b) si la sociedad fuere demandada judicialmente o se le embarguen los bienes por cualquier clase de accion que afecte considerablemente su patrimonio; c) En caso de declaratoria de quiebra, o concurso de acreedores, inhabilidad e incapacidad de uno o varios de los que firman el presente documento. SEXTO. En caso de causarse impuesto de timbre sobre el presente titulo valor, su costo correra a cargo del deudor y sera pagado a favor de la Administracion de Impuestos directamente, a la firma del presente pagare. SEPTIMO. Autorizo desde ahora para que el presente titulo valor sea transferido por endoso segun lo establecido en el articulo 651 y siguientes del Codigo del Comercio. OCTAVO.';
    END IF;

    IF VTCPOBLACPAR IS NOT NULL THEN
    vquery := vquery ||' Para todos los efectos el domicilio de las partes se fija en la ciudad de '||VTCPOBLACPAR||'.';
    END IF;

    vquery := vquery ||' Para constancia se firma';

    IF VTCPOBLACFIR IS NOT NULL THEN
    vquery := vquery ||' en la ciudad de '||VTCPOBLACFIR;
    END IF;

    BEGIN
    LETRAS := null;
    ret := f_numlet (8,VDIA,8,LETRAS);
    END;
    vquery := vquery ||' a los '|| LETRAS||'('||VDIA||') dias del mes de '||VTMES||'del a'|| CHR(38)||'ntilde;o '||VANIO||'.';


    vquery := vquery ||CHR(39) || ' FROM DUAL';

    execute immediate vquery into vquery2;

     RETURN vquery2;

   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject || vobject, 1,
                     'Error no controlado', SQLERRM || dbms_utility.format_error_backtrace);
         RETURN vquery2;   -- Error no controlado

    END f_getPagareCartera;
    --FIN TCS 309 08/03/2019 AP

END pac_contragarantias;
/