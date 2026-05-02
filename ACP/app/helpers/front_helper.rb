module FrontHelper
    def localized(obj, field)
        obj[0].send("#{field}_#{I18n.locale}")
    end
end
