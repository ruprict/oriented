class Oriented::Listener
  include Java::ComOrientechnologiesOrientCoreDb::ODatabaseListener

	def onCreate(db)
  end

	def onDelete(db)
  end

	def onOpen(db) 
	end

	def onBeforeTxBegin(db)
  end

  def onBeforeTxRollback(db)
    # puts "BEFORE ROLLBACK"
  end

	def onAfterTxRollback(db)
  end

	def onBeforeTxCommit(db)
      # puts "ON BEFORE TX COMMIT"
	end

	def onAfterTxCommit(db)
    Oriented::IdentityMap.clear
  end

	def onClose(db)
	end

  # args= ODatabase, string, string
  def onCorruptionRepairDatabase(odb, iReason, iWhatWillbeFixed)
  end
end
