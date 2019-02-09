#!/usr/bin/env python3

import wx
import os
import wx.grid as gridlib
import random
from time import sleep

print('wx version : {}'.format(wx.version()))
current_player = 'Human (X)'
game_over = False

win_state = [[(0,0),(0,1),(0,2)],
[(1,0),(1,1),(1,2)],
[(2,0),(2,1),(2,2)],
[(0,0),(1,0),(2,0)],
[(0,1),(1,1),(2,1)],
[(0,2),(1,2),(2,2)],
[(0,0),(1,1),(2,2)],
[(0,2),(1,1),(2,0)]
]

def CheckWins(grid):
    human_state=  []
    machine_state = []
    for i in range(3):
        for j in range(3):
            value = grid.GetCellValue(i, j)
            if value == 'X':
                human_state.append((i,j))
            elif value == 'O':
                machine_state.append((i,j))
                for elem in win_state:
                    if set(elem).issubset(human_state):
                        return 'HUMAN_WINS'
                    elif set(elem).issubset(machine_state):
                        return 'MACHINE_WINS'
                    else:
                        return False

def CheckAvailableCells(grid):
    available_cells = []
    for i in range(3):
        for j in range(3):
            value = grid.GetCellValue(i,j)
            if value == '' or value == None:
                available_cells.append((i,j))
    return available_cells

def GetCellsByValue(grid, value):
    requested_cells = []
    for i in range(3):
        for j in range(3):
            v = grid.GetCellValue(i,j)
            if v == value:
                requested_cells.append((i,j))
    return requested_cells

def empty_cells(state):
    pass

def SwitchPlayer(player):
    global current_player
    if player == 'Human (X)':
        current_player = 'Machine (O)'
    else:
        current_player = 'Human (X)'

class SimpleGrid(wx.grid.Grid):
    def __init__(self, parent):
        wx.grid.Grid.__init__(self, parent, -1)
        self.CreateGrid(3, 3)
        self.SetRowLabelSize(0)
        self.SetColSize(0, 100)
        self.SetColSize(1, 100)
        self.SetColSize(2, 100)
        self.SetRowSize(0, 50)
        self.SetRowSize(1, 50)
        self.SetRowSize(2, 50)
        #Set Listeners
        self.Bind(gridlib.EVT_GRID_CELL_LEFT_CLICK, self.OnClickCell)

def OnClickCell(self,event):
    global game_over
    if game_over == True:
        return
    row, col = event.GetRow(), event.GetCol()
    grid_win = self.GetGridWindow()
    cellFont  = wx.Font(pointSize=16, family=wx.FONTFAMILY_ROMAN,
    style=wx.FONTSTYLE_NORMAL, weight=wx.FONTWEIGHT_NORMAL,
    underline=False, faceName='Utopia')
    value = self.GetCellValue( row,col)
    #Chech current player
    if value != 'X' and value != 'O' and current_player == 'Human (X)':
        self.SetCursor(wx.StockCursor(wx.CURSOR_HAND))
        self.SetCellValue( row, col, 'X')
        self.SetCellBackgroundColour(row, col, wx.RED)
        self.SetCellTextColour(row, col, wx.BLUE)
        self.SetCellFont(row,col,cellFont)
        self.SetReadOnly( row, col)
        #check_wins
        whoWins =  CheckWins(self)
    #automated machine
    if whoWins == False:
        SwitchPlayer(current_player)
        self.playerLbl.SetLabel('Current Player : %s' % current_player)
        #1 Check available
        available_cells = CheckAvailableCells(self)

    if len(available_cells) == 0:
        game_over = True
        self.winnerLbl.SetForegroundColour(wx.Colour(226,116,13))
        self.winnerLbl.SetLabel('Draw game !!!')
    else:
        nextPos = random.choice(available_cells)
        self.SetCursor(wx.StockCursor(wx.CURSOR_HAND))
        self.SetCellValue( nextPos[0], nextPos[1], 'O')
        self.SetCellBackgroundColour(nextPos[0], nextPos[1], wx.GREEN)
        self.SetCellTextColour(nextPos[0], nextPos[1], wx.BLUE)
        self.SetCellFont(nextPos[0],nextPos[1],cellFont)
        self.SetReadOnly( nextPos[0], nextPos[1])
        whoWins =  CheckWins(self)
    if whoWins == False:
        SwitchPlayer(current_player)
        self.playerLbl.SetLabel('Current Player : %s' % current_player)
    elif whoWins == 'HUMAN_WINS':
        game_over = True
        self.winnerLbl.SetForegroundColour(wx.Colour(31,216,25))
        self.winnerLbl.SetLabel('You win !!!')
    elif whoWins == "MACHINE_WINS":
        game_over = True
        self.winnerLbl.SetForegroundColour(wx.Colour(239,11,11))
        self.winnerLbl.SetLabel('You loose !!!')
    elif whoWins == 'HUMAN_WINS':
        game_over = True
        self.winnerLbl.SetForegroundColour(wx.Colour(31,216,25))
        self.winnerLbl.SetLabel('You win !!!')
    elif whoWins == "MACHINE_WINS":
        game_over = True
        self.winnerLbl.SetForegroundColour(wx.Colour(239,11,11))
        self.winnerLbl.SetLabel('You loose !!!')
    elif value != 'X' and value != 'O' and current_player == '#Machine (O)':
        self.SetCursor(wx.StockCursor(wx.CURSOR_HAND))
        self.SetCellValue( row, col, 'O')
        self.SetCellBackgroundColour(row, col, wx.GREEN)
        self.SetCellTextColour(row, col, wx.BLUE)
        self.SetCellFont(row,col,cellFont)
        self.SetReadOnly( row, col)
        whoWins =  CheckWins(self)
    if whoWins == False:
        SwitchPlayer(current_player)
        self.playerLbl.SetLabel('Current Player : %s' % current_player)
    elif whoWins == 'HUMAN_WINS':
        game_over = True
        self.winnerLbl.SetForegroundColour(wx.Colour(31,216,25))
        self.winnerLbl.SetLabel('You win !!!')
    elif whoWins == "MACHINE_WINS":
        game_over = True
        self.winnerLbl.SetForegroundColour(wx.Colour(239,11,11))
        self.winnerLbl.SetLabel('You loose !!!')
    else:
        grid_win.SetCursor(wx.StockCursor(wx.CURSOR_CROSS))

class MainWindow(wx.Frame):
    def __init__(self, parent, title):
        wx.Frame.__init__(self, parent, title=title, size=(350,350))
        working_dir = os.path.dirname(os.path.abspath(__file__))
        #Frame Icon
        _icon = wx.Icon()
        _icon.CopyFromBitmap(wx.Bitmap("TIC_TAC_TOE.png", wx.BITMAP_TYPE_ANY))
        self.SetIcon(_icon)
        self.panel = wx.Panel(self, wx.ID_ANY)
        sizer = wx.BoxSizer(wx.VERTICAL)
        self.panel.grid = SimpleGrid(self.panel)
        self.panel.grid.playerLbl = wx.StaticText(self.panel,label='Current Player : %s' % current_player)
        self.panel.grid.winnerLbl = wx.StaticText(self.panel,label='')
        sizer.Add(self.panel.grid.playerLbl,0,wx.ALL,5)
        sizer.Add(self.panel.grid,0,wx.ALL,0)
        sizer.Add(self.panel.grid.winnerLbl,0,wx.ALL,5)
        self.panel.SetSizer(sizer)
        self.CreateStatusBar() # A Statusbar in the bottom of the window
        # Setting up the menu.
        filemenu = wx.Menu()
        # wx.ID_ABOUT and wx.ID_EXIT are standard IDs provided by wxWidgets.
        newGameMenuItem = filemenu.Append(wx.ID_NEW,"&New","Play new game")
        filemenu.AppendSeparator()
        aboutMenuItem = filemenu.Append(wx.ID_ABOUT, "&About","Tic Tac Toe game")
        filemenu.AppendSeparator()
        exitMenuItem = filemenu.Append(wx.ID_EXIT,"E&xit"," Terminate the program")
        # Creating the menubar.
        menuBar = wx.MenuBar()
        menuBar.Append(filemenu,"&Game") # Adding the "filemenu" to the MenuBar
        self.SetMenuBar(menuBar)  # Adding the MenuBar to the Frame content.
        # Event handling
        self.Bind(wx.EVT_MENU, self.OnAbout, aboutMenuItem)
        self.Bind(wx.EVT_MENU, self.OnExit, exitMenuItem)
        self.Bind(wx.EVT_MENU, self.OnNewGame, newGameMenuItem)
        self.Centre()
        self.Show(True)

def OnAbout(self,event):
    # A message dialog box with an OK button. wx.OK is a standard ID in wxWidgets.
    dlg = wx.MessageDialog( self, "Tic Tac Toe Game", "About", wx.OK)
    dlg.ShowModal() # Show it
    dlg.Destroy() # finally destroy it when finished.

def OnExit(self,event):
    self.Close(True)

def OnNewGame(self,event):
    dlg = wx.MessageDialog( self, "Are you sure ?", "Confirm New Game", wx.OK | wx.CANCEL | wx.ICON_QUESTION)
    result = dlg.ShowModal() # Show it
    dlg.Destroy()
    if result == wx.ID_OK:
        global current_player
        current_player = 'Human (X)'
        global game_over
        game_over = False
        self.panel.grid.playerLbl.SetLabel('Current Player : %s' % current_player)
        self.panel.grid.winnerLbl.SetLabel('')
        #Clear all cells
        for i in range(3):
            for j in range(3):
                self.panel.grid.SetCellValue(i, j, "")
                self.panel.grid.SetCellBackgroundColour(i, j, None)
    else:
        print('Do Nothing !')
        app = wx.App(False)
        frame = MainWindow(None, "Tic Tac Toe")
        frame.Show(True)
        app.MainLoop()

# Note that you need to put icon (TIC_TAC_TOE.png in the same folder)
