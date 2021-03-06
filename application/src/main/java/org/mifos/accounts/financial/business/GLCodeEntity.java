/*
 * Copyright (c) 2005-2010 Grameen Foundation USA
 * All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
 *
 * See also http://www.apache.org/licenses/LICENSE-2.0.html for an
 * explanation of the license and how it is applied.
 */

package org.mifos.accounts.financial.business;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.OneToOne;
import javax.persistence.Table;

@Entity
@Table(name = "GL_CODE")
public class GLCodeEntity implements Serializable {

    private Short glcodeId;
    private String glcode;
    private COABO associatedCOA;

    protected GLCodeEntity() {
        this(null, null);
    }

    public GLCodeEntity(Short glcodeId, String glcode) {
        this.glcodeId = glcodeId;
        this.glcode = glcode;
        associatedCOA = null;
    }

    @Id
    @GeneratedValue
    @Column(name = "GLCODE_ID", nullable = false)
    public Short getGlcodeId() {
        return glcodeId;
    }

    @Column(name = "GLCODE_VALUE")
    public String getGlcode() {
        return glcode;
    }
    @OneToOne(fetch = FetchType.EAGER, mappedBy = "associatedGlcode")
    public COABO getAssociatedCOA() {
        return associatedCOA;
    }

    protected void setGlcodeId(Short glcodeId) {
        this.glcodeId = glcodeId;
    }

    protected void setGlcode(String glcode) {
        this.glcode = glcode;
    }

    protected void setAssociatedCOA(COABO associatedCOA) {
        this.associatedCOA = associatedCOA;
    }

    @Override
    public String toString() {
        return glcode;
    }
}
