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

package org.mifos.accounts.business;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;

import org.mifos.accounts.util.helpers.AccountTypes;

/**
 * This class depicts the different account types. Obsolete; replaced by
 * {@link AccountTypes}.
 */
@Entity
@Table(name = "ACCOUNT_TYPE")
public class AccountTypeEntity implements Serializable {

    private Short accountTypeId;
    private String description;
    private Integer lookUpId;

    public AccountTypeEntity() {
    }

    public AccountTypeEntity(Integer lookUpId) {
        this.lookUpId = lookUpId;
    }

    public AccountTypeEntity(String description, Integer lookUpId) {
        this.description = description;
        this.lookUpId = lookUpId;
    }

    public AccountTypeEntity(Short accountTypeId) {
        this.accountTypeId = accountTypeId;
    }

    @Id
    @GeneratedValue
    @Column(name = "ACCOUNT_TYPE_ID", nullable = false)
    public Short getAccountTypeId() {
        return this.accountTypeId;
    }

    public void setAccountTypeId(Short accountTypeId) {
        this.accountTypeId = accountTypeId;
    }

    @Column(name = "DESCRIPTION")
    public String getDescription() {
        return this.description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Column(name = "LOOKUP_ID", nullable = false)
    public Integer getLookUpId() {
        return this.lookUpId;
    }

    public void setLookUpId(Integer lookUpId) {
        this.lookUpId = lookUpId;
    }

}
