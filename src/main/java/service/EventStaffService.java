/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.EventStaffDAO;
import java.util.Collections;
import java.util.List;
import model.Event;

/**
 *
 * @author BT
 */
public class EventStaffService {

    private final EventStaffDAO eventStaffDAO;

    public EventStaffService() {
        this.eventStaffDAO = new EventStaffDAO();
    }

    public List<Event> getAssignedEvents(int staffId) {
        if (staffId <= 0) {
            return Collections.emptyList();
        }

        return eventStaffDAO.getAssignedEvents(staffId);
    }
}
