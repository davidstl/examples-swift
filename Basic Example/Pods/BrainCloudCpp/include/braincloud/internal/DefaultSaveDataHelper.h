#ifndef _DEFAULTSAVEDATAHELPER_H_
#define _DEFAULTSAVEDATAHELPER_H_

#include "braincloud/internal/SaveDataHelper.h"

namespace BrainCloud
{
    class DefaultSaveDataHelper : public SaveDataHelper
    {
    public:
        virtual void initialize(const char * companyName, const char * appName, const char * wrapperName = "");

        virtual void saveData(const char * key, const char * data);
        virtual std::string readData(const char * key);
        virtual void deleteData(const char * key);

    protected:
        friend class SaveDataHelper;

        DefaultSaveDataHelper();
    };
}

#endif
