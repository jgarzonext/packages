--------------------------------------------------------
--  DDL for Package PAC_INT_BATCH_OUT_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_INT_BATCH_OUT_MV" is

  TYPE rpolizas_batch IS RECORD(
      fechaCarga    	  VARCHAR2(8),
	  plzAplicacion		  VARCHAR2(3),
	  plzEmpresa		  VARCHAR2(2),
	  plzCentro			  VARCHAR2(4),
	  plzAfijo			  VARCHAR2(3),
	  plzContrato		  VARCHAR2(7),
	  plzDigito			  VARCHAR2(1),
	  fechaAlta			  VARCHAR2(8),
	  fechaBaja			  VARCHAR2(8),
	  fechaEfecto		  VARCHAR2(8),
	  fechaVencimiento	  VARCHAR2(8),
	  fechaPosicion		  VARCHAR2(8),
	  producto			  VARCHAR2(5),
	  valorProvision	  VARCHAR2(15),
	  impAsegurado		  VARCHAR2(15),
	  usuario			  VARCHAR2(5),
	  asoAplicacion		  VARCHAR2(3),
	  asoEmpresa		  VARCHAR2(2),
	  asoCentro			  VARCHAR2(4),
	  asoAfijo			  VARCHAR2(3),
	  asoContrato		  VARCHAR2(7),
	  asoDigito			  VARCHAR2(1),
	  vinAplicacion		  VARCHAR2(3),
	  vinEmpresa		  VARCHAR2(2),
	  vinCentro			  VARCHAR2(4),
	  vinAfijo			  VARCHAR2(3),
	  vinContrato		  VARCHAR2(7),
	  vinDigito			  VARCHAR2(1)
   );

   TYPE rtomadores_batch IS RECORD(
       clavesip        VARCHAR2(9)
   );

   TYPE ttomadores_batch IS TABLE OF rtomadores_batch INDEX BY BINARY_INTEGER;

   function datos_polizas (pfcarga in date, psseguro in number,
     ppolizas out rpolizas_batch, ptomadores out ttomadores_batch) return number;

   function fichero_polizas (pfcarga in date) return number;

-----------------------------------------------------------

   TYPE rmovimientos_batch IS RECORD(
      fechaCarga    	  VARCHAR2(8),
	  plzAplicacion		  VARCHAR2(3),
	  plzEmpresa		  VARCHAR2(2),
	  plzCentro			  VARCHAR2(4),
	  plzAfijo			  VARCHAR2(3),
	  plzContrato		  VARCHAR2(7),
	  plzDigito			  VARCHAR2(1),
	  oficina			  VARCHAR2(4),
	  concepto			  VARCHAR2(3),
	  nroMvto			  VARCHAR2(5),
	  naturaleza		  VARCHAR2(1),
	  importe			  VARCHAR2(15),
	  fechaValor		  VARCHAR2(8),
	  fechaMov			  VARCHAR2(8),
	  valorProvision	  VARCHAR2(15),
	  valorVencimiento	  VARCHAR2(15),
	  valorFallecimiento  VARCHAR2(15)
   );


   function datos_movimientos (pfcarga in date, psseguro in number, pnnumlin in number,
     pmovimientos out rmovimientos_batch) return number;

   function fichero_movimientos (pfcarga in date, psintbatch in number) return number;

-----------------------------------------------------------

   TYPE rimpagados_batch IS RECORD(
      fechaCarga    	  VARCHAR2(8),
	  plzAplicacion		  VARCHAR2(3),
	  plzEmpresa		  VARCHAR2(2),
	  plzCentro			  VARCHAR2(4),
	  plzAfijo			  VARCHAR2(3),
	  plzContrato		  VARCHAR2(7),
	  plzDigito			  VARCHAR2(1),
	  fechaSituacion	  VARCHAR2(8),
	  tipoProceso		  VARCHAR2(3),
	  tipoGarantia		  VARCHAR2(3),
	  fechaImpago		  VARCHAR2(8),
	  importeImpago		  VARCHAR2(15),
	  importeComplement	  VARCHAR2(15),
	  moneda			  VARCHAR2(1),
	  claveIncidencia	  VARCHAR2(3),
	  producto			  VARCHAR2(5),
	  fechaVencimiento	  VARCHAR2(8)
   );


   function datos_impagados (pfcarga in date, psseguro in number, pnrecibo in number,
     pimporte in number, pfimpago in date, pimpagados out rimpagados_batch) return number;

   function fichero_impagados (pfcarga in date) return number;


-----------------------------------------------------------

   TYPE rventas_batch IS RECORD(
      fechaCarga    	  VARCHAR2(8),
	  empresaOrigen		  VARCHAR2(2),
	  centroOrigen		  VARCHAR2(4),
	  aplicacionOrigen	  VARCHAR2(3),
	  subaplicacionOrigen VARCHAR2(3),
	  fechaContratacion	  VARCHAR2(8),
	  moneda			  VARCHAR2(3),
	  claseVenta		  VARCHAR2(5),
	  tipoOperacion		  VARCHAR2(1),
	  plzAplicacion		  VARCHAR2(3),
	  plzEmpresa		  VARCHAR2(2),
	  plzCentro			  VARCHAR2(4),
	  plzAfijo			  VARCHAR2(3),
	  plzContrato		  VARCHAR2(7),
	  plzDigito			  VARCHAR2(1),
	  subcontrato		  VARCHAR2(7),
	  prodAplicacion	  VARCHAR2(3),
	  prodProducto		  VARCHAR2(5),
	  tipoGarantia		  VARCHAR2(3),
	  tblCondiciones	  VARCHAR2(5),
	  importeInversion	  VARCHAR2(15),
	  importeRecursos	  VARCHAR2(15),
	  importeResto		  VARCHAR2(15),
	  fechaVencimiento	  VARCHAR2(8),
	  TAE				  VARCHAR2(7),
	  interes			  VARCHAR2(1)
   );

   function datos_ventas (pfcarga in date, psseguro in number, pnmovimi in number,
     pcmovseg in number, pcmotmov in number, pextr in varchar2,
	 pventas out rventas_batch) return number;

   function fichero_ventas (pfcarga in date) return number;

end;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_INT_BATCH_OUT_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INT_BATCH_OUT_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INT_BATCH_OUT_MV" TO "PROGRAMADORESCSI";
