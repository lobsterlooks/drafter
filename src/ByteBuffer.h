//
//  ByteBuffer.h
//  markdownparser
//
//  Created by Zdenek Nemec on 4/18/14.
//  Copyright (c) 2014 Apiary Inc. All rights reserved.
//

#ifndef MARKDOWNPARSER_BYTEBUFFER_H
#define MARKDOWNPARSER_BYTEBUFFER_H

#include <string>
#include <vector>

namespace mdp {
    
    /**
     *  \brief Source data byte buffer
     *
     *  Note this is a byte buffer, a sequence of
     *  UTF8 bytes note necessarily characters.
     */
    typedef std::string ByteBuffer;
    
    /** A generic continuous range */
    struct Range {
        size_t location;
        size_t length;
        
        Range(size_t loc = 0, size_t len = 0)
        : location(loc), length(len) {}
    };
    
    /** Range of bytes */
    typedef Range BytesRange;
    
    /** Range of characters */
    typedef Range CharactersRange;
    
    /** A generic set of non-continuous of ranges */
    template<typename T>
    class RangeSet : public std::vector<T> {
    public:
        
        /** Append another range set to this one, merging continuous blocks */
        inline void append(const RangeSet& val)
        {
            if (val.empty())
                return;
            if (this->empty() ||
                val.front().location != this->back().location + this->back().length) {
                this->insert(this->end(), val.begin(), val.end());
            }
            else {
                // merge
                this->back().length += val.front().length;
                
                if (val.size() > 1) {
                    this->insert(this->end(), ++val.begin(), val.end());
                }
            }
        }
    };
    
    /** Set of non-continuous byte ranges */
    typedef RangeSet<BytesRange> BytesRangeSet;
    
    /** Set of non-continuous character ranges */
    typedef RangeSet<CharactersRange> CharactersRangeSet;
    
    /** Map Ranges of bytes to ranges of characters */
    CharactersRangeSet MapBytesToCharacters(const BytesRangeSet& rangeSet, const ByteBuffer& byteBuffer);
}

#endif
