namespace :create_document do
  desc "Se crean documento en dec para ser ocupados posteriormente por un proceso"
  task :create_on_dec, [:code_file] => [:environment] do |t, args|

    #Variables a utilizar
    @route = "https://5cap.dec.cl/api/v1"
    @api_key = "fc6ec9a59fac7b43208220e143e2f516c18c6986"
    @range = 20
    @type_document_id = []
    @to_create = []
    
    #Login del Usuario (JSON.pretty_generate(my_object))
    login = Typhoeus.post("#{@route}/auth/login",
                          headers:{ "Content-Type": "application/json","X-API-KEY": "#{ @api_key  }" },
                          body:JSON.dump({ "user_name": "BONO", 
                                           "user_pin": "ExbrJk" }))

    @login_request = JSON.parse(login.body) #session id : @login_request['session_id']
    #Saber los tipos de documentos de una institucion type_document_id
    document_type = Typhoeus.get("#{@route}/document_type/list",
                                  headers:{ "Content-Type": "application/json","X-API-KEY": "#{ @api_key  }" },
                                  params:{ "institution": " #{ args[:code_file] }", "session_id": "#{ @login_request['session_id'] }" })

    JSON.parse(document_type.body)["result"]["document_types"].each { |x| @type_document_id << x['type_code']  if x['type_code'].present? } 
    #Crear Documentos Vacios
    @type_document_id.each do |ids|
      create = (@range - TableService.where(busy: false, id_code: "#{ ids }").count(:busy)).to_i
      puts create <= 0 ? "|> Tipo de Documento #{ids} en el tope " : "|>> Se crearan #{ create > 0 ? create : 0 } para el Tipo de Documento #{ ids }"      

      (1..create).each do |i| 
        new_document = Typhoeus.post("#{@route}/documents/create",
                                      headers:{ "Content-Type": "application/json","X-API-KEY": "#{ @api_key  }" },
                                      body:JSON.dump( { "type_code": "#{ ids }",
                                                        "institution": " #{ args[:code_file] } ",
                                                        "name": "Reserverd",
                                                        "creator": "",
                                                        "signers_roles": [],
                                                        "signers_institutions": [],
                                                        "signers_emails": [],
                                                        "signers_ruts": [],
                                                        "signers_type": [],
                                                        "signers_order": [],
                                                        "signers_notify": [],
                                                        "tags": [],
                                                        "field_tags": [],
                                                        "field_tags_values": [],
                                                        "comment": "",
                                                        "file": "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6tPAF+SUB76PmixwjZxhnYeor7HJWzeh3bDPnzVQsVnrV4BLx9nD1ErD77+YxQQXnm88nYToCmVuZHN0cmVhbQplbmRvYmoKCjkgMCBvYmoKPDwvVHlwZS9Gb250L1N1YnR5cGUvVHJ1ZVR5cGUvQmFzZUZvbnQvQkFBQUFBK0xpYmVyYXRpb25TZXJpZgovRmlyc3RDaGFyIDAKL0xhc3RDaGFyIDExCi9XaWR0aHNbNzc3IDcyMiA1MDAgNTAwIDQ0MyA1MDAgNDQzIDMzMyAyNTAgNTAwIDY2NiA0NDMgXQovRm9udERlc2NyaXB0b3IgNyAwIFIKL1RvVW5pY29kZSA4IDAgUgo+PgplbmRvYmoKCjEwIDAgb2JqCjw8L0YxIDkgMCBSCj4+CmVuZG9iagoKMTEgMCBvYmoKPDwvRm9udCAxMCAwIFIKL1Byb2NTZXRbL1BERi9UZXh0XQo+PgplbmRvYmoKCjEgMCBvYmoKPDwvVHlwZS9QYWdlL1BhcmVudCA0IDAgUi9SZXNvdXJjZXMgMTEgMCBSL01lZGlhQm94WzAgMCA2MTEuOTcxNjUzNTQzMzA3IDc5MS45NzE2NTM1NDMzMDddL0dyb3VwPDwvUy9UcmFuc3BhcmVuY3kvQ1MvRGV2aWNlUkdCL0kgdHJ1ZT4+L0NvbnRlbnRzIDIgMCBSPj4KZW5kb2JqCgo0IDAgb2JqCjw8L1R5cGUvUGFnZXMKL1Jlc291cmNlcyAxMSAwIFIKL01lZGlhQm94WyAwIDAgNjExIDc5MSBdCi9LaWRzWyAxIDAgUiBdCi9Db3VudCAxPj4KZW5kb2JqCgoxMiAwIG9iago8PC9UeXBlL0NhdGFsb2cvUGFnZXMgNCAwIFIKL09wZW5BY3Rpb25bMSAwIFIgL1hZWiBudWxsIG51bGwgMF0KL0xhbmcoZXMtQ0wpCj4+CmVuZG9iagoKMTMgMCBvYmoKPDwvQ3JlYXRvcjxGRUZGMDA1NzAwNzIwMDY5MDA3NDAwNjUwMDcyPgovUHJvZHVjZXI8RkVGRjAwNEMwMDY5MDA2MjAwNzIwMDY1MDA0RjAwNjYwMDY2MDA2OTAwNjMwMDY1MDAyMDAwMzYwMDJFMDAzMD4KL0NyZWF0aW9uRGF0ZShEOjIwMTgwOTIxMTA0NTA0LTAzJzAwJyk+PgplbmRvYmoKCnhyZWYKMCAxNAowMDAwMDAwMDAwIDY1NTM1IGYgCjAwMDAwMDY2NjQgMDAwMDAgbiAKMDAwMDAwMDAxOSAwMDAwMCBuIAowMDAwMDAwMjE5IDAwMDAwIG4gCjAwMDAwMDY4MzMgMDAwMDAgbiAKMDAwMDAwMDIzOSAwMDAwMCBuIAowMDAwMDA1ODE0IDAwMDAwIG4gCjAwMDAwMDU4MzUgMDAwMDAgbiAKMDAwMDAwNjAzMCAwMDAwMCBuIAowMDAwMDA2MzczIDAwMDAwIG4gCjAwMDAwMDY1NzcgMDAwMDAgbiAKMDAwMDAwNjYwOSAwMDAwMCBuIAowMDAwMDA2OTMyIDAwMDAwIG4gCjAwMDAwMDcwMjkgMDAwMDAgbiAKdHJhaWxlcgo8PC9TaXplIDE0L1Jvb3QgMTIgMCBSCi9JbmZvIDEzIDAgUgovSUQgWyA8ODk5MEY0OUY0ODYyNUU0QURFQTk5MTRDODcwODczRjM+Cjw4OTkwRjQ5RjQ4NjI1RTRBREVBOTkxNEM4NzA4NzNGMz4gXQovRG9jQ2hlY2tzdW0gL0QyMDhFODlFNTZFODQ2REYyNjlEMjQ1MEJDMjE5OTdECj4+CnN0YXJ0eHJlZgo3MjA0CiUlRU9GCg==",
                                                        "file_mime": "application/pdf",
                                                        "session_id": " #{ @login_request['session_id'] } "} ))

        @id_dec_document =  JSON.parse(new_document.body)

        if @id_dec_document['status'].to_i == 200

          insert_on_table= TableService.new(dec_code: @id_dec_document['result']['code'] ,id_code: ids, busy: false)
          
          if insert_on_table.save
             puts "#{i}. Documento: #{ @id_dec_document['result']['code'] } Creado"
          else
            puts "Problemas al guardar #{ @id_dec_document['result']['code'] }"
          end
        else
          puts @id_dec_document['message']
          break
        end

      end
    end

  end
end