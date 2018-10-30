namespace :upload_document do
  desc "Carga los documentos al DEC5"
  task upload: :environment do

    @route = "https://5cap.dec.cl/api/v1"
    @api_key = "fc6ec9a59fac7b43208220e143e2f516c18c6986"
    @i = 0 #SACAR PARA PASARLO A PRODUCCIÓN

    login_user = Typhoeus.post("#{@route}/auth/login",
                          headers:{ "Content-Type": "application/json","X-API-KEY": "#{ @api_key  }" },
                          body:JSON.dump({ "user_name": "BONO", 
                                           "user_pin": "ExbrJk" }))

    @login_request = JSON.parse(login_user.body) #session id : @login_request['session_id']

    if @login_request['status'] == 200
      loop  do
        document_save = TableService.where(busy: true).first
        puts 'En ejecución....'
        break if document_save == nil

        @i += 1 #SACAR PARA PASARLO A PRODUCCIÓN
        break if @i == 5 #SACAR PARA PASARLO A PRODUCCIÓN

        update = update_document(document_save)
        if update['status'].to_i == 200 #updatear documento
          status = []
          puts "Procesando para compartir ..."
          share = share_document(document_save)

          if share.all? {|x| x['status'].to_i == 200}
            puts "Hola" #PENDIENTE <|======================================================================================================5
            puts "|> Procesos Finalizados Con exito"
          else 
            byebug
            error = share
            save_log(document_save, error)
          end
          share = share_document(document_save)
        else
          error = update
          save_log(document_save, error)
        end
      end      
    else
      puts "#{@login_request['error']}"
    end
    puts " |>  No quedan documentos a guardar "
  end

  def update_document(document_save)
    updateDocument = Typhoeus.post("#{@route}/documents/update",
                                    headers:{ "Content-Type": "application/json","X-API-KEY": "#{ @api_key  }" },
                                    body:JSON.dump( { "code": "#{ document_save.dec_code }",
                                                      "institution": "#{ document_save.institution }",
                                                      "file": "#{ document_save.file }",
                                                      "file_mime": "application/pdf",
                                                      "notify": 0,
                                                      "session_id": "#{ @login_request['session_id'] }" } )) 

    response = JSON.parse(updateDocument.body)
    response
  end

  def share_document(document_save)

    response = []

    document_save.signatories.each do |firmante|
      unless firmante['Auditoria'].present?
        share_document = Typhoeus.post("#{@route}/sign/finger",
                                      headers:{ "Content-Type": "application/json","X-API-KEY": "#{ @api_key  }" },
                                      body:JSON.dump( { "code": "document_save.dec_code",
                                                        "role": "#{ firmante['ROL'] }",
                                                        "institution": "document_save.institution",
                                                        "ruts": [],
                                                        "session_id": "#{ @login_request['session_id'] }" }))

        response << JSON.parse(share_document.body)
      end
    end

    response
  end

  def save_log(document_save, error)
    byebug
    save_log = Log.new( dec_code: document_save.dec_code ,
                        id_code: document_save.id_code ,
                        institution: document_save.institution ,
                        description: document_save.description ,
                        file_mime: document_save. file_mime,
                        file: document_save.file ,
                        signatories: document_save.signatories ,
                        tags: document_save.tags ,
                        related_document: document_save.related_document ,
                        status: error['status'] ,
                        mesaje_status: error['message'],
                        id_action: document_save.id_action ,
                        type_action: document_save.type_action )
    if save_log.save
      delete_database(document_save)
    else
      puts "Problemas al guardar en la base de datos"
    end
  end

  def delete_database(document_save)
    document_save.destroy
    puts "Documento eliminado de la tabla principal y guardado en log"
  end

end