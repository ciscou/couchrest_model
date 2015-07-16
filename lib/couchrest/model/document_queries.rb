module CouchRest
  module Model
    module DocumentQueries
      extend ActiveSupport::Concern

      module ClassMethods

        # Wrapper for the master design documents all method to provide
        # a total count of entries.
        def count
          all.count
        end

        # Wrapper for the master design document's first method on all view.
        def first
          all.first
        end

        # Wrapper for the master design document's last method on all view.
        def last
          all.last
        end

        # Load a document from the database by id
        # No exceptions will be raised if the document isn't found
        #
        # ==== Returns
        # Object:: if the document was found
        # or
        # Nil::
        # 
        # === Parameters
        # id<String, Integer>:: Document ID
        # db<Database>:: optional option to pass a custom database to use
        def get(id, db = database)
          begin
            get!(id, db)
          rescue
            nil
          end
        end
        alias :find :get

        # Load a document from the database by id
        # An exception will be raised if the document isn't found
        #
        # ==== Returns
        # Object:: if the document was found
        # or
        # Exception
        # 
        # === Parameters
        # id<String, Integer>:: Document ID
        # db<Database>:: optional option to pass a custom database to use
        def get!(id, db = database)
          raise CouchRest::Model::DocumentNotFound if id.blank?

          doc = db.get id
          build_from_database(doc)
        rescue CouchRest::NotFound
          raise CouchRest::Model::DocumentNotFound
        end
        alias :find! :get!

        # Load an array of documents from the database by ids
        # No exceptions will be raised if any of the documents isn't found
        #
        # ==== Returns
        # Array of Object:: for the documents that were found,
        # or
        # Nil:: for the documents that were not found
        #
        # === Parameters
        # ids<String, Integer>:: Documents IDs
        # db<Database>:: optional option to pass a custom database to use
        def get_bulk(ids, db = database)
          get_bulk!(ids, db) { nil }
        end
        alias :find_bulk :get_bulk

        # Load an array of documents from the database by ids
        # An exception will be raised if any of the documents isn't found
        # (unless you provide a default value block)
        #
        # ==== Returns
        # Array of Object::
        # or
        # Exception
        #
        # === Parameters
        # ids<String, Integer>:: Documents IDs
        # db<Database>:: optional option to pass a custom database to use
        # block<Proc>:: this block will be called for not found documents.
        # If present, no exception will be raised.
        def get_bulk!(ids, db = database, &block)
          response = db.get_bulk(ids)
          response['rows'].map do |row|
            if row.key?('doc')
              doc = row['doc']
              build_from_database(doc)
            else
              if block
                block.call(row)
              else
                raise CouchRest::Model::DocumentNotFound
              end
            end
          end
        end
        alias :find_bulk! :get_bulk!

      end

    end
  end
end
