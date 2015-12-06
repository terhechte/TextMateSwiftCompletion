//
//  document.h
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

#ifndef document_h
#define document_h

#include <string>
#include <vector>

using namespace std;

namespace document
{
    struct document_t : std::enable_shared_from_this<document_t>
    {
        bool is_modified () const;
        std::string __attribute__((weak_import)) path () const;
    };
    typedef std::shared_ptr<document_t>       document_ptr;
};

#endif /* document_h */
