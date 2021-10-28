// Code generated by go-swagger; DO NOT EDIT.

package models

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"encoding/json"
	"strconv"

	"github.com/go-openapi/errors"
	"github.com/go-openapi/strfmt"
	"github.com/go-openapi/swag"
	"github.com/go-openapi/validate"
)

// Inventory inventory
//
// swagger:model inventory
type Inventory struct {

	// bmc address
	BmcAddress string `json:"bmc_address,omitempty"`

	// bmc v6address
	BmcV6address string `json:"bmc_v6address,omitempty"`

	// boot
	Boot *Boot `json:"boot,omitempty"`

	// cpu
	CPU *CPU `json:"cpu,omitempty"`

	// disks
	Disks []*Disk `json:"disks"`

	// gpus
	Gpus []*Gpu `json:"gpus"`

	// hostname
	Hostname string `json:"hostname,omitempty"`

	// interfaces
	Interfaces []*Interface `json:"interfaces"`

	// memory
	Memory *Memory `json:"memory,omitempty"`

	// routes
	Routes []*Route `json:"routes"`

	// system vendor
	SystemVendor *SystemVendor `json:"system_vendor,omitempty"`

	// timestamp
	Timestamp int64 `json:"timestamp,omitempty"`

	// tpm version
	// Enum: [none 1.2 2.0]
	TpmVersion string `json:"tpm_version,omitempty"`
}

// Validate validates this inventory
func (m *Inventory) Validate(formats strfmt.Registry) error {
	var res []error

	if err := m.validateBoot(formats); err != nil {
		res = append(res, err)
	}

	if err := m.validateCPU(formats); err != nil {
		res = append(res, err)
	}

	if err := m.validateDisks(formats); err != nil {
		res = append(res, err)
	}

	if err := m.validateGpus(formats); err != nil {
		res = append(res, err)
	}

	if err := m.validateInterfaces(formats); err != nil {
		res = append(res, err)
	}

	if err := m.validateMemory(formats); err != nil {
		res = append(res, err)
	}

	if err := m.validateRoutes(formats); err != nil {
		res = append(res, err)
	}

	if err := m.validateSystemVendor(formats); err != nil {
		res = append(res, err)
	}

	if err := m.validateTpmVersion(formats); err != nil {
		res = append(res, err)
	}

	if len(res) > 0 {
		return errors.CompositeValidationError(res...)
	}
	return nil
}

func (m *Inventory) validateBoot(formats strfmt.Registry) error {

	if swag.IsZero(m.Boot) { // not required
		return nil
	}

	if m.Boot != nil {
		if err := m.Boot.Validate(formats); err != nil {
			if ve, ok := err.(*errors.Validation); ok {
				return ve.ValidateName("boot")
			}
			return err
		}
	}

	return nil
}

func (m *Inventory) validateCPU(formats strfmt.Registry) error {

	if swag.IsZero(m.CPU) { // not required
		return nil
	}

	if m.CPU != nil {
		if err := m.CPU.Validate(formats); err != nil {
			if ve, ok := err.(*errors.Validation); ok {
				return ve.ValidateName("cpu")
			}
			return err
		}
	}

	return nil
}

func (m *Inventory) validateDisks(formats strfmt.Registry) error {

	if swag.IsZero(m.Disks) { // not required
		return nil
	}

	for i := 0; i < len(m.Disks); i++ {
		if swag.IsZero(m.Disks[i]) { // not required
			continue
		}

		if m.Disks[i] != nil {
			if err := m.Disks[i].Validate(formats); err != nil {
				if ve, ok := err.(*errors.Validation); ok {
					return ve.ValidateName("disks" + "." + strconv.Itoa(i))
				}
				return err
			}
		}

	}

	return nil
}

func (m *Inventory) validateGpus(formats strfmt.Registry) error {

	if swag.IsZero(m.Gpus) { // not required
		return nil
	}

	for i := 0; i < len(m.Gpus); i++ {
		if swag.IsZero(m.Gpus[i]) { // not required
			continue
		}

		if m.Gpus[i] != nil {
			if err := m.Gpus[i].Validate(formats); err != nil {
				if ve, ok := err.(*errors.Validation); ok {
					return ve.ValidateName("gpus" + "." + strconv.Itoa(i))
				}
				return err
			}
		}

	}

	return nil
}

func (m *Inventory) validateInterfaces(formats strfmt.Registry) error {

	if swag.IsZero(m.Interfaces) { // not required
		return nil
	}

	for i := 0; i < len(m.Interfaces); i++ {
		if swag.IsZero(m.Interfaces[i]) { // not required
			continue
		}

		if m.Interfaces[i] != nil {
			if err := m.Interfaces[i].Validate(formats); err != nil {
				if ve, ok := err.(*errors.Validation); ok {
					return ve.ValidateName("interfaces" + "." + strconv.Itoa(i))
				}
				return err
			}
		}

	}

	return nil
}

func (m *Inventory) validateMemory(formats strfmt.Registry) error {

	if swag.IsZero(m.Memory) { // not required
		return nil
	}

	if m.Memory != nil {
		if err := m.Memory.Validate(formats); err != nil {
			if ve, ok := err.(*errors.Validation); ok {
				return ve.ValidateName("memory")
			}
			return err
		}
	}

	return nil
}

func (m *Inventory) validateRoutes(formats strfmt.Registry) error {

	if swag.IsZero(m.Routes) { // not required
		return nil
	}

	for i := 0; i < len(m.Routes); i++ {
		if swag.IsZero(m.Routes[i]) { // not required
			continue
		}

		if m.Routes[i] != nil {
			if err := m.Routes[i].Validate(formats); err != nil {
				if ve, ok := err.(*errors.Validation); ok {
					return ve.ValidateName("routes" + "." + strconv.Itoa(i))
				}
				return err
			}
		}

	}

	return nil
}

func (m *Inventory) validateSystemVendor(formats strfmt.Registry) error {

	if swag.IsZero(m.SystemVendor) { // not required
		return nil
	}

	if m.SystemVendor != nil {
		if err := m.SystemVendor.Validate(formats); err != nil {
			if ve, ok := err.(*errors.Validation); ok {
				return ve.ValidateName("system_vendor")
			}
			return err
		}
	}

	return nil
}

var inventoryTypeTpmVersionPropEnum []interface{}

func init() {
	var res []string
	if err := json.Unmarshal([]byte(`["none","1.2","2.0"]`), &res); err != nil {
		panic(err)
	}
	for _, v := range res {
		inventoryTypeTpmVersionPropEnum = append(inventoryTypeTpmVersionPropEnum, v)
	}
}

const (

	// InventoryTpmVersionNone captures enum value "none"
	InventoryTpmVersionNone string = "none"

	// InventoryTpmVersionNr12 captures enum value "1.2"
	InventoryTpmVersionNr12 string = "1.2"

	// InventoryTpmVersionNr20 captures enum value "2.0"
	InventoryTpmVersionNr20 string = "2.0"
)

// prop value enum
func (m *Inventory) validateTpmVersionEnum(path, location string, value string) error {
	if err := validate.EnumCase(path, location, value, inventoryTypeTpmVersionPropEnum, true); err != nil {
		return err
	}
	return nil
}

func (m *Inventory) validateTpmVersion(formats strfmt.Registry) error {

	if swag.IsZero(m.TpmVersion) { // not required
		return nil
	}

	// value enum
	if err := m.validateTpmVersionEnum("tpm_version", "body", m.TpmVersion); err != nil {
		return err
	}

	return nil
}

// MarshalBinary interface implementation
func (m *Inventory) MarshalBinary() ([]byte, error) {
	if m == nil {
		return nil, nil
	}
	return swag.WriteJSON(m)
}

// UnmarshalBinary interface implementation
func (m *Inventory) UnmarshalBinary(b []byte) error {
	var res Inventory
	if err := swag.ReadJSON(b, &res); err != nil {
		return err
	}
	*m = res
	return nil
}
